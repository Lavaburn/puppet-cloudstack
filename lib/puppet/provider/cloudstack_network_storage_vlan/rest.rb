require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_network_storage_vlan).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Networking - Storage VLAN IP Settings"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createStorageNetworkIpRange
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteStorageNetworkIpRange
      return
    end 

    updateStorageNetworkIpRange
  end  

  def self.instances
    result = Array.new      
    
    list = get_objects(:listStorageNetworkIpRange, "storagenetworkiprange")
    if list != nil
      list.each do |object|    
        map = getStorageNetworkIpRange(object)
        if map != nil
          Puppet.debug "Storage Network IP Range: "+map.inspect
          result.push(new(map))
        end
      end 
    end   
         
    result 
  end
  
  def self.getObject(podid, startip)    
    params = { :podid => podid, :startip => startip }
      
    list = get_objects(:listStorageNetworkIpRange, "storagenetworkiprange", params)
    if list != nil
      list.each do |object|    
        return getStorageNetworkIpRange(object)
      end
    end   
        
    raise "StorageNetworkIpRange could not be found: "+params.inspect    
  end
      
  def self.getStorageNetworkIpRange(object)         
    if object["id"] != nil              
      pod = genericLookup(:listPods, 'pod', 'id', object["podid"], {}, 'name')

      #zone = genericLookup(:listZones, 'zone', 'id', object["zoneid"], {}, 'name')
      #SYSTEM DEFAULT ???  -  network = genericLookup(:listNetworks, 'network', 'id', object["networkid"], {}, 'name') unless object["networkid"] == nil
                
      {
        :id                 => object["id"],
        :name               => pod+'_'+object["startip"],   
        :vlan               => object["vlan"].to_s,
        :podid              => object["podid"],
        :pod                => pod,
        :startip            => object["startip"],
        :endip              => object["endip"],
        :netmask            => object["netmask"],
        :gateway            => object["gateway"],    
        :ensure           => :present
#        :zoneid             => object["zoneid"],          
#        :zone               => zone, 
#        :networkid          => object["networkid"],
#        :network            => network,    
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createStorageNetworkIpRange
    Puppet.debug "Create Storage Network (IP Range) "+resource[:name]
 
    podid = self.class.genericLookup(:listPods, 'pod', 'name', resource[:pod], {}, 'id')
      
    params = {            
      :podid              => podid,   
      :vlan               => resource[:vlan],       
      :startip            => resource[:startip],
      :endip              => resource[:endip],
      :netmask            => resource[:netmask],
      :gateway            => resource[:gateway],
    }
    
    Puppet.debug "createStorageNetworkIpRange PARAMS = "+params.inspect
    response = self.class.http_get('createStorageNetworkIpRange', params)
    
    self.class.wait_for_async_call(response["jobid"])
  end

  def deleteStorageNetworkIpRange
    Puppet.debug "Delete Storage Network (IP Range) "+resource[:name]
     
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deleteStorageNetworkIpRange PARAMS = "+params.inspect
    response = self.class.http_get('deleteStorageNetworkIpRange', params)
    
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updateStorageNetworkIpRange
    Puppet.debug "Update Storage Network (IP Range) "+resource[:name]
    
    id = lookupId
    
    podid = self.class.genericLookup(:listPods, 'pod', 'name', @property_hash[:pod], {}, 'id')
    currentObject = self.class.getObject(podid, @property_hash[:startip])
                
    if resource[:pod] != currentObject[:pod]
      raise "StorageNetworkIpRange does not allow updating pod (and gateway) !"      
    end       
    if resource[:gateway] != currentObject[:gateway]
      raise "StorageNetworkIpRange does not allow updating gateway (and pod) !"
    end
      
    podid = self.class.genericLookup(:listPods, 'pod', 'name', resource[:pod], {}, 'id')
    
    params = { 
      :id                 => id,       
      :vlan               => resource[:vlan],       
      :startip            => resource[:startip],
      :endip              => resource[:endip],
      :netmask            => resource[:netmask],      
    }
    # TODO UPDATE IS BROKEN ??? startip overlap...
    
    Puppet.debug "updateStorageNetworkIpRange PARAMS = "+params.inspect
    response = self.class.http_get('updateStorageNetworkIpRange', params)
    
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def lookupId 
    podid = self.class.genericLookup(:listPods, 'pod', 'name', resource[:pod], {}, 'id')

    params = { :podid => podid, :startip => resource[:startip] }
  
    list = self.class.get_objects(:listStorageNetworkIpRange, "storagenetworkiprange", params)
    if list != nil
      list.each do |object|    
        return object["id"]
      end
    end   
    
    raise "StorageNetworkIpRange could not be found: "+params.inspect
  end
end