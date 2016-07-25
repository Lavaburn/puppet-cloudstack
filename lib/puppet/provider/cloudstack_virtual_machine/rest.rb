require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_virtual_machine).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Virtual Machine"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :absent
      destroy_virtualMachine
      return 
    end
    
    if @property_flush[:ensure] != :absent
      return if deploy_virtualMachine 
    end
    
    update_virtualMachine
    
    if @property_flush[:ensure] == :running
      start_virtualMachine
      return 
    end
    
    if @property_flush[:ensure] == :stopped
      stop_virtualMachine
      return 
    end
  end  

  def self.instances
    result = Array.new
    
    list = get_objects(:listVirtualMachines, "virtualmachine", { :listall => true })
    if list != nil
      list.each do |object|    
        result.push new(getVirtualMachine(object))
      end      
    end
        
    return result
  end
  
  def self.getObject(id)     
    params = { :listall => true, :id => id }
    list = get_objects(:listVirtualMachines, "virtualmachine", params)
    if list != nil    
      list.each do |object|    
        return getVirtualMachine(object)
      end
    end
    
    raise "Could not find Virtual Machine with ID = #{id}"
  end
  
  def self.getVirtualMachine(object)
    default_network_name = nil
    extra_networks = Array.new
      
    if object["nic"] != nil
      object["nic"].each do |nic|
        if nic["isdefault"] 
          default_network_name = nic["networkname"]
        else        
          extra_networks.push(nic["networkname"])
        end
      end      
    end
    #Puppet.debug "NIC DEFAULT NAME = "+default_network_name.inspect
    
    userdata = nil
    params = { "virtualmachineid" => object["id"] } 
    userdataHash = get_objects(:getVirtualMachineUserData, "virtualmachineuserdata", params)
    if userdataHash["userdata"] != nil
      userdata = Base64.decode64(userdataHash["userdata"])
    end
    
    affinityGroups = Array.new 
    if object["affinitygroup"] != nil
      object["affinitygroup"].each do |group|
        affinityGroups.push(group["name"])
      end      
    end
    
    # displayname, group, haenable, hostname, project ?
    {
      :id              => object["id"],
      :name            => object["name"],
      :template        => object["templatename"],
      :account         => object["account"],
      :domain          => object["domain"],
      :zone            => object["zonename"],
      :serviceoffering => object["serviceofferingname"],
      :keypair         => object["keypair"],
      :default_network => default_network_name,
      :userdata        => userdata,
      :affinitygroups  => affinityGroups,
      :state           => object["state"].downcase,
      :extra_networks  => extra_networks,
      :ensure          => :present
    }
  end
  
  def self.getNIClist(id)
    nics = Hash.new
    
    params = { :listall => true, :id => id }
    list = get_objects(:listVirtualMachines, "virtualmachine", params)
    if list != nil
      list.each do |object|    
        if object["nic"] != nil
          object["nic"].each do |nic|
            nics[object["nic"]["network_name"]] = object["nic"]["nic_id"]
          end
        end         
      end
    end
    
    nics
  end
  
  # TYPE SPECIFIC    
  def setState(state)
    @property_flush[:ensure] = state
  end  
  
  def getState
    @property_hash[:state]
  end
  
  private
  def deploy_virtualMachine      
    #Puppet.debug "Deploying Virtual Machine "+resource[:name]
        
    if @property_hash.empty?  
      Puppet.debug "Deploying VirtualMachine #{resource[:name]}"
      
      serviceofferingid = self.class.genericLookup(:listServiceOfferings, 'serviceoffering', 'name', resource[:serviceoffering], {}, 'id')
      zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
      networkid = self.class.genericLookup(:listNetworks, 'network', 'name', resource[:default_network], { :listall => true }, 'id')        
      templateid = self.class.genericLookup(:listTemplates, 'template', 'name', resource[:template], { :templatefilter => "all" }, 'id')  
              
      # Required parameters
      resourceHash = {
        :name               => resource[:name],
        :keypair            => resource[:keypair],
        :serviceofferingid  => serviceofferingid,
        :templateid         => templateid,
        :zoneid             => zoneid,
        :networkids         => networkid,   
      }
      # displayname, group
      
      # Optional parameters     
      if resource[:userdata] != nil
        resourceHash[:userdata] = Base64.encode64(resource[:userdata])
      end
      
      if resource[:affinitygroups] != nil
        resourceHash[:affinitygroupnames] = resource[:affinitygroups].join(",")        
      end

      if resource[:account] != nil
        domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')
        resourceHash[:account] = resource[:account]    
        resourceHash[:domainid] = domainid
      end
            
      #API Call
      #Puppet.debug "deployVirtualMachine PARAMS = "+resourceHash.inspect      
      response = self.class.http_get('deployVirtualMachine', resourceHash)
      
      self.class.wait_for_async_call(response["jobid"])
      
      return true
    end
    
    false
  end
  
  def update_virtualMachine
    updated = false    
    currentObject = self.class.getObject(@property_hash[:id])
    
    # Userdata
    if resource[:userdata] != currentObject[:userdata]
      Puppet.debug "Updating Userdata for VirtualMachine #{resource[:name]}"
      
      userdata = Base64.encode64(resource[:userdata])      
      params = { :id => @property_hash[:id], :userdata => userdata }
      response = self.class.http_get('updateVirtualMachine', params)
      
      updated = true
    end
        
    # Service Offering 
    if resource[:serviceoffering] != currentObject[:serviceoffering]
      Puppet.debug "Updating Service Offering for VirtualMachine #{resource[:name]}"
      
      if @property_hash[:state] != "stopped"        
        if @property_flush[:ensure] == :stopped
          stop_virtualMachine
        else
          raise "The Service Offering can not be updated when the VM is running!"
        end
      end
      
      serviceofferingid = nil
      params = { "name" => resource[:serviceoffering] } 
      list = self.class.get_objects(:listServiceOfferings, "serviceoffering", params)
      if list != nil        
        list.collect do |object|    
          serviceofferingid = object["id"]
        end
      end
      if serviceofferingid == nil
        raise "Service Offering does not exist. Name = "+resource[:serviceoffering].inspect
      end
      
      params = { :id => @property_hash[:id], :serviceofferingid => serviceofferingid }
      response = self.class.http_get('changeServiceForVirtualMachine', params)
            
      updated = true
    end
    
    # SSH keypair
    if resource[:keypair] != currentObject[:keypair]
      Puppet.debug "Updating SSH Keypair for VirtualMachine #{resource[:name]}"
      
      if @property_hash[:state] != "stopped"
        if @property_flush[:ensure] == :stopped
          stop_virtualMachine
        else
          raise "The SSH Keypair can not be updated when the VM is running!"
        end
      end
      
      params = { :id => @property_hash[:id], :keypair => resource[:keypair] }
      response = self.class.http_get('resetSSHKeyForVirtualMachine', params)      
      self.class.wait_for_async_call(response["jobid"])
            
      updated = true
    end
    
    # Affinity Group
    if resource[:affinitygroups] != currentObject[:affinitygroups]
      Puppet.debug "Updating Affinity Groups for VirtualMachine #{resource[:name]}"
      
      if @property_hash[:state] != "stopped"
        if @property_flush[:ensure] == :stopped
          stop_virtualMachine
        else
          raise "The Affinity Groups can not be updated when the VM is running!"
        end
      end
          
      params = { :id => @property_hash[:id], :affinitygroupnames => resource[:affinitygroups].join(",")  }
      response = self.class.http_get('updateVMAffinityGroup', params)      
      self.class.wait_for_async_call(response["jobid"])
      
      updated = true
    end

    # Affinity Group
    if resource[:extra_networks] != currentObject[:extra_networks]
      Puppet.debug "Updating Extra Networks for VirtualMachine #{resource[:name]}"
      
#      if @property_hash[:state] != "stopped"
#        if @property_flush[:ensure] == :stopped
#          stop_virtualMachine
#        else
#          raise "A NIC can not be added/removed when the VM is running!"
#        end
#      end
      
      additions = resource[:extra_networks] - currentObject[:extra_networks]
      additions.each do |addition|
        networkid = self.class.genericLookup(:listNetworks, 'network', 'name', addition, { :listall => true }, 'id')  
        params = { :networkid => networkid, :virtualmachineid => @property_hash[:id] }
        response = self.class.http_get('addNicToVirtualMachine', params)      
        self.class.wait_for_async_call(response["jobid"])     
      end
      
      nic_list = self.class.getNIClist(@property_hash[:id])

      removals = currentObject[:extra_networks] - resource[:extra_networks]
      removals.each do |removal|
        params = { :nicid => nic_list[removal], :virtualmachineid => @property_hash[:id] }
        response = self.class.http_get('removeNicFromVirtualMachine', params)      
        self.class.wait_for_async_call(response["jobid"])      
      end
            
      updated = true
    end    
      
    if (!updated)
      # VirtualMachine does not provide a general update function
      Puppet.warning("Cloudstack API does not provide a general update function for the  VirtualMachine.")
    end
    
    # Update the current info    
    # @property_hash = self.class.get_OBJ(resource[:name])    
  end

  def destroy_virtualMachine
    Puppet.debug "Destroying VirtualMachine #{resource[:name]}"
    
    params = { :id => @property_hash[:id] }
    response = self.class.http_get('destroyVirtualMachine', params)
    
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def start_virtualMachine      
    if @property_hash[:state] != "running"
      Puppet.debug "Starting VirtualMachine #{resource[:name]}"
      
      params = { :id => @property_hash[:id] }
      response = self.class.http_get('startVirtualMachine', params)
      
      self.class.wait_for_async_call(response["jobid"])
    end
  end
  
  def stop_virtualMachine      
    if @property_hash[:state] != "stopped"
      Puppet.debug "Stopping VirtualMachine #{resource[:name]}"
      
      params = { :id => @property_hash[:id] }
      response = self.class.http_get('stopVirtualMachine', params)
      
      self.class.wait_for_async_call(response["jobid"])
    end    
  end 
end