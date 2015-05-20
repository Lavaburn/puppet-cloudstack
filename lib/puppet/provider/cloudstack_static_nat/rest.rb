require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_static_nat).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Static NAT"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      enable_static_nat
      return
    end
    
    if @property_flush[:ensure] == :absent
      disable_static_nat
      return
    end 

    update_static_nat
  end  

  def self.instances
    list = get_objects(:listVirtualMachines, "virtualmachine", { :listall => true })
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getStaticNAT(object)
      if map != nil
        #Puppet.debug "STATIC NAT FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
    
  def self.getStaticNAT(object)   
    if object["publicip"] != nil  
      {
        :name               => object["publicip"],
        :ipaddress_id       => object["publicipid"],
        :virtual_machine    => object["name"],
        :virtual_machine_id => object["id"],        
        :ensure             => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def enable_static_nat    
    # Puppet won't allow you to reach here if IP was allocated (considering prefetch works...)
    Puppet.debug "Enable Static NAT between "+resource[:name]+" and "+resource[:virtual_machine]
         
    vm = getVirtualMachine(resource[:virtual_machine])
    ip = getIpAddress(resource[:name])
      
    params = { 
      :ipaddressid      => ip["id"],
      :virtualmachineid => vm["id"],
    }
    #Puppet.debug "enableStaticNat PARAMS = "+params.inspect
    response = self.class.http_get('enableStaticNat', params)  
  end

  def disable_static_nat
    # Puppet won't allow you to reach here if IP was not allocated (considering prefetch works...)
    Puppet.debug "Disable Static NAT from "+resource[:name]+" (VM = "+resource[:virtual_machine]+")"

    ip = getIpAddress(resource[:name])
      
    params = { 
      :ipaddressid      => ip["id"],
    }
    #Puppet.debug "disableStaticNat PARAMS = "+params.inspect
    response = self.class.http_get('disableStaticNat', params)      
    self.class.wait_for_async_call(response["jobid"])   
  end
  
  def update_static_nat
    Puppet.debug "Static NAT for IP "+resource[:name]+" was changed to new VM. Disabling old rule and enabling new one"
    
    disable_static_nat 
    sleep 5
    enable_static_nat
  end
  
  def getVirtualMachine(name)
    params = { :name  => name, :listall => true }
    list = self.class.get_objects(:listVirtualMachines, "virtualmachine", params)
    if list != nil
      list.each do |object|
        return object
      end
    end   
        
    raise "Could not find VirtualMachine "+name 
  end
  
  def getIpAddress(ipaddress)
    params = { :ipaddress  => ipaddress }
    list = self.class.get_objects(:listPublicIpAddresses, "publicipaddress", params)
    if list != nil
      list.each do |object|
        return object
      end
    end
    
    raise "Could not find IP Address "+ipaddress+". Use cloudstack_public_ip to allocate more IPs if required." 
  end
end