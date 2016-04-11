require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_secondary_storage).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Secondary Storage"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createSecondaryStorage
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteSecondaryStorage
      return
    end 

    raise "Secondary Storage does not provide update functionality !"
  end  

  def self.instances
    list = get_objects(:listImageStores, "imagestore")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|   
      map = getSecondaryStorage(object)
      if map != nil
        #Puppet.debug "Image Store (Secondary Storage): "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listImageStores, "imagestore", params).collect do |object|    
      return getSecondaryStorage(object)
    end
  end
    
  def self.getSecondaryStorage(object)     
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
  def createSecondaryStorage
    Puppet.debug "Create Secondary Storage "+resource[:name]
 
    zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
      
    params = {         
      :name     => resource[:name],   
      :url      => resource[:url],   
      :zoneid   => zoneid,
      :provider => resource[:provider],   
    }
            
    Puppet.debug "addImageStore PARAMS = "+params.inspect
    response = self.class.http_get('addImageStore', params)
  end

  def deleteSecondaryStorage
    Puppet.debug "Delete Secondary Storage "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deleteImageStore PARAMS = "+params.inspect
    response = self.class.http_get('deleteImageStore', params)           
  end
  
  def lookupId 
    return self.class.genericLookup(:listImageStores, 'imagestore', 'name', resource[:name], {}, 'id')    
  end
end