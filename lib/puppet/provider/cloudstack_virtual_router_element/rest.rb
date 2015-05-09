require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_virtual_router_element).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack VirtualRouter Element"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :absent
      raise "API does not provide a delete function for Virtual Router Element"
      return
    end 
    
    if @property_flush[:ensure] != :absent
      return if createVirtualRouterElement
    end
    
    if @property_flush[:ensure] == :enabled
      enableVirtualRouterElement
      return
    end 
        
    if @property_flush[:ensure] == :disabled
      disableVirtualRouterElement
      return
    end 
    
    raise "API does not provide any generic update functions for Virtual Router Element"
  end  

  def self.instances
    result = Array.new  
    
    list = get_objects(:listVirtualRouterElements, "virtualrouterelement")
    if list != nil
      list.each do |object|    
        map = getVirtualRouterElement(object)
        if map != nil
          #Puppet.debug "Virtual Router Element: "+map.inspect
          result.push(new(map))
        end
      end   
    end 

    result 
  end
      
  def self.getVirtualRouterElement(object) 
    if object["nspid"] != nil
      
      physicalnetworkid = nil
      provider = nil
      found = false
      
      list = get_objects(:listNetworkServiceProviders, "networkserviceprovider")
      if list != nil
        list.each do |nsp|   
          if nsp["id"] == object["nspid"]
            physicalnetworkid = nsp["physicalnetworkid"]
            provider = nsp["name"]
            found = true
          end
        end   
      end 
      
      if !found
        raise "Could not find Network Service Provider with ID = "+object["nspid"]
      end
      
      physicalnetwork = genericLookup(:listPhysicalNetworks, "physicalnetwork", 'id', physicalnetworkid, {}, 'name')
        
      {
        :id                 => object["id"],
        :name               => physicalnetwork+'_'+provider,
        :providertype       => provider,   
        :physicalnetworkid  => physicalnetworkid,
        :physicalnetwork    => physicalnetwork,   
        :state              => object["enabled"]?"enabled":"disabled",
        :ensure             => :present
      }
    end
  end
  
  # TYPE SPECIFIC 
  def setState(state)
    @property_flush[:ensure] = state
  end  
  
  def getState
    @property_hash[:state]
  end    
   
  private
  def createVirtualRouterElement
    if @property_hash.empty?            
      Puppet.debug "Create VirtualRouter Element "+resource[:name]
        
      physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, "physicalnetwork", 'name', resource[:physicalnetwork], {}, 'id') 
            
      params = { :physicalnetworkid => physicalnetworkid}
      nspid = self.class.genericLookup(:listNetworkServiceProviders, "networkserviceprovider", 'name', resource[:providertype], params, 'id') 
        
      params = {         
        :nspid            => nspid,  
        # FAILS !!!   :providertype     => resource[:providertype],   
      }
          
      Puppet.debug "createVirtualRouterElement PARAMS = "+params.inspect
      response = self.class.http_get('createVirtualRouterElement', params)                     
      self.class.wait_for_async_call(response["jobid"])  
      
      true
    end
      
    false
  end
  
  def updateState(state)
    id = lookupId
           
    params = { 
      :id        => id,   
      :enabled   => state,
    }
    #Puppet.debug "configureVirtualRouterElement PARAMS = "+params.inspect
    response = self.class.http_get('configureVirtualRouterElement', params)             
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def enableVirtualRouterElement
    Puppet.debug "Enable VirtualRouter Element "+resource[:name]
          
    updateState(true)    
  end
  
  def disableVirtualRouterElement
    Puppet.debug "Disable VirtualRouter Element "+resource[:name]

    updateState(false)
  end
  
  def lookupId  
    physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, "physicalnetwork", 'name', resource[:physicalnetwork], {}, 'id') 
             
    params = { :physicalnetworkid => physicalnetworkid}
    nspid = self.class.genericLookup(:listNetworkServiceProviders, "networkserviceprovider", 'name', resource[:providertype], params, 'id') 
    
    return self.class.genericLookup(:listVirtualRouterElements, "virtualrouterelement", 'nspid', nspid, {}, 'id')
  end
end