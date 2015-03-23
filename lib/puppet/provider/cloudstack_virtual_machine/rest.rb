require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_virtual_machine).provide :rest, :parent => Puppet::Provider::Rest do
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
    get_objects(:listVirtualMachines, "virtualmachine").collect do |object|    
      new(getVirtualMachine(object))
    end      
  end
  
  def self.getObject(id) 
    params = { :id => id }
    get_objects(:listVirtualMachines, "virtualmachine", params).collect do |object|    
      return getVirtualMachine(object)
    end
  end
  
  def self.getVirtualMachine(object)
    default_network_name = nil  
    object["nic"].collect do |nic|
      if nic["isdefault"] 
        default_network_name = nic["networkname"]
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
    object["affinitygroup"].collect do |group|
      affinityGroups.push(group["name"])
    end
    
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
      :ensure          => :present
    }
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
    #Puppet.debug "TODO: (VM) deploy_virtualMachine? => "+@property_hash.inspect
        
    if @property_hash.empty?  
      Puppet.debug "Deploying VirtualMachine #{resource[:name]}"
      
      # Convert names to IDs
      serviceofferingid = nil
      zoneid = nil
      #domainid = nil
      templateid = nil
      networkid = nil
      
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
      
      params = { "name" => resource[:zone] } 
      list = self.class.get_objects(:listZones, "zone", params)
      if list != nil        
        list.collect do |object|    
          zoneid = object["id"]
        end
      end
      if zoneid == nil
        raise "Zone does not exist. Name = "+resource[:zone].inspect
      end
            
      #TODO ONLY FOR ROOT ADMIN ...
#      params = { "name" => resource[:domain] } 
#      list = self.class.get_objects(:listDomains, "domain", params)
#      list.collect do |object|    
#        domainid = object["id"]
#      end
#      if domainid == nil
#        raise "Domain does not exist. Name = "+resource[:domain].inspect 
#      end
      
      #"featured", "self", "selfexecutable","sharedexecutable","executable", and "community".                   
      params = { "name" => resource[:template], "templatefilter" => "executable" } 
      list = self.class.get_objects(:listTemplates, "template", params)
      if list != nil        
        list.collect do |object|    
          templateid = object["id"]
        end
      end
      if templateid == nil
        raise "Template does not exist. Name = "+resource[:template].inspect
      end
      
      list = self.class.get_objects(:listNetworks, "network")
      if list != nil 
        list.collect do |object|  
          if resource[:default_network] == object["name"]
            networkid = object["id"]
          end
        end
      end
      if networkid == nil
        raise "Network does not exist. Name = "+resource[:default_network].inspect
      end
            
      # Required parameters
      resourceHash = {
        :name               => resource[:name],
        :keypair            => resource[:keypair],
          
        #TODO NOT REQUIRED BY USER LOGIN ??? :account            => resource[:account],
        #TODO NOT REQUIRED BY USER LOGIN ??? :domainid           => domainid,
          
        :serviceofferingid  => serviceofferingid,
        :templateid         => templateid,
        :zoneid             => zoneid,
        :networkids         => networkid,
          
        

        #:displayname => ???
        #:affinitygroupids OR :affinitygroupnames => CSV
        #:customid  =>  ROOT Admin only
        #:deploymentplanner  =>  ROOT Admin only
        #:details => custom parameters
        #:diskofferingid  TPL = Template object, DATA Disk Volume; TPL = ISO object, ROOT Disk Volume        
        #:size =>  size for the DATADISK volume. Mutually exclusive with diskOfferingId 
        #:displayvm whether to the display the vm to the end user   
        #:group => Group
        #:hostid  =>  ROOT Admin only
        #:hypervisor => required when hypervisor info is not set on the ISO/Template
        #:ip6address => the ipv6 address
        #:ipaddress => the ip address
        #:iptonetworklist => Can't be specified with networkIds parameter. Example: iptonetworklist[0].ip=10.10.10.11&iptonetworklist[0].ipv6=fc00:1234:5678::abcd&iptonetworklist[0].networkid=uuid - requests to use ip 10.10.10.11 in network id=uuid 
        #:keyboard   de,de-ch,es,fi,fr,fr-be,fr-ch,is,it,jp,nl-be,no,pt,uk,us
        #:rootdisksize  resize root disk on deploy.
        #:securitygroupids OR :securitygroupnames => CSV (BASIC ZONE)        
        
        #TODO ??? based on ensure?
        #:startvm (DEFAULT = true)          
      }
       
      # Optional parameters     
      if resource[:userdata] != nil
        resourceHash[:userdata] = Base64.encode64(resource[:userdata])
      end
      
      if resource[:affinitygroups] != nil
        resourceHash[:affinitygroupnames] = resource[:affinitygroups].join(",")        
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