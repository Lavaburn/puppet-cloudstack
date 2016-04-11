require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_network_provider).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Network Service Provider"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :absent
      deleteNetworkServiceProvider
      return
    end 
    
    if @property_flush[:ensure] != :absent
      return if createNetworkServiceProvider
    end
    
    if @property_flush[:ensure] == :enabled
      enableNetworkServiceProvider
      return
    end 
    
    if @property_flush[:ensure] == :shutdown
      shutdownNetworkServiceProvider
      return
    end 
    
    if @property_flush[:ensure] == :disabled
      disableNetworkServiceProvider
      return
    end 
    
    updateNetworkServiceProvider
  end  

  def self.instances
    result = Array.new  
    
    list = get_objects(:listNetworkServiceProviders, "networkserviceprovider")
    if list != nil
      list.each do |object|    
        map = getNetworkServiceProvider(object)
        if map != nil
          #Puppet.debug "Network Service Provider: "+map.inspect
          result.push(new(map))
        end
      end   
    end 

    result 
  end
      
  def self.getNetworkServiceProvider(object) 
    if object["name"] != nil  
      physicalnetwork = genericLookup(:listPhysicalNetworks, "physicalnetwork", 'id', object["physicalnetworkid"], {}, 'name')
        
      {
        :id                 => object["id"],
        :name               => physicalnetwork+'_'+object["name"],
        :service_provider   => object["name"],   
        :physicalnetworkid  => object["physicalnetworkid"],
        :physicalnetwork    => physicalnetwork,         
        :state              => object["state"].downcase,
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
  def createNetworkServiceProvider
    if @property_hash.empty?      
      Puppet.debug "Create Network Service Provider "+resource[:name]
        
      physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, "physicalnetwork", 'name', resource[:physicalnetwork], {}, 'id') 
        
      params = {         
        :name                 => resource[:service_provider],   
        :physicalnetworkid    => physicalnetworkid,  
      }
          
      Puppet.debug "addNetworkServiceProvider PARAMS = "+params.inspect
      response = self.class.http_get('addNetworkServiceProvider', params)                     
      self.class.wait_for_async_call(response["jobid"])  
        
      return true
    end
    
    false
  end

  def deleteNetworkServiceProvider
    Puppet.debug "Delete Network Service Provider "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deleteNetworkServiceProvider PARAMS = "+params.inspect
#    response = self.class.http_get('deleteNetworkServiceProvider', params) 
#    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updateNetwork
    Puppet.debug "Update Network Service Provider "+resource[:name]
      
    raise "Network Service Provider only allows update for servicelist, which is currently not supported by this Puppet Module"
  end  
  
  def updateState(state)
    id = lookupId
           
    params = { 
      :id      => id,   
      :state   => state,
    }
    Puppet.debug "updateNetworkServiceProvider PARAMS = "+params.inspect
    response = self.class.http_get('updateNetworkServiceProvider', params)             
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def enableNetworkServiceProvider
    Puppet.debug "Enable Network Service Provider "+resource[:name]
          
    updateState('Enabled')    
  end
  
  def disableNetworkServiceProvider
    Puppet.debug "Disable Network Service Provider "+resource[:name]

    updateState('Disabled')
  end
  
  def shutdownNetworkServiceProvider
    Puppet.debug "Shutdown Network Service Provider "+resource[:name]

    updateState('Shutdown')
  end
  
  def lookupId  
    physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, "physicalnetwork", 'name', resource[:physicalnetwork], {}, 'id')
    
    params = { :physicalnetworkid => physicalnetworkid }
    return self.class.genericLookup(:listNetworkServiceProviders, "networkserviceprovider", 'name', resource[:service_provider], {}, 'id')
  end
end