require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_secondary_staging_storage).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Secondary Staging Storage"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createSecondaryStagingStorage
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteSecondaryStagingStorage
      return
    end 

    raise "Secondary Staging Storage does not provide update functionality !"
  end  

  def self.instances
    list = get_objects(:listSecondaryStagingStores, "imagestore")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|   
      map = getSecondaryStagingStorage(object)
      if map != nil
        #Puppet.debug "Secondary Staging Store: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listSecondaryStagingStores, "imagestore", params).collect do |object|    
      return getSecondaryStagingStorage(object)
    end
  end
    
  def self.getSecondaryStagingStorage(object)     
    if object["name"] != nil  
      {
        :id               => object["id"],
        :name             => object["name"],             
        :scope            => object["scope"],  
        :zoneid           => object["zoneid"],
        :zone             => object["zonename"],           
        :url              => object["url"],
        :provider         => object["providername"],
        :ensure           => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createSecondaryStagingStorage
    Puppet.debug "Create Secondary Staging Storage "+resource[:name]
 
    zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
      
    params = {
      :url      => resource[:url],   
      :zoneid   => zoneid,
      :provider => resource[:provider],   
    }
            
    Puppet.debug "createSecondaryStagingStore PARAMS = "+params.inspect
    response = self.class.http_get('createSecondaryStagingStore', params)
  end

  def deleteSecondaryStagingStorage
    Puppet.debug "Delete Secondary Staging Storage "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deleteSecondaryStagingStore PARAMS = "+params.inspect
    response = self.class.http_get('deleteSecondaryStagingStore', params)           
  end
  
  def lookupId 
    return self.class.genericLookup(:listSecondaryStagingStores, 'imagestore', 'name', resource[:name], {}, 'id')    
  end
end