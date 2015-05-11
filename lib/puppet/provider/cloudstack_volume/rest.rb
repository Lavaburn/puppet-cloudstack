require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_volume).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Volume"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createVolume
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteVolume
      return
    end 
    
    # TODO ATTACH TO VM ??

    raise "Update volume is currently not implemented. Not much to do anyway..."
  end  

  def self.instances
    result = Array.new  
    
    list = get_objects(:listVolumes, "volume")
    if list != nil
      list.each do |object|
        map = getVolume(object)
        if map != nil
          Puppet.debug "VOLUME FOUND: "+map.inspect
          result.push(new(map))
        end
      end       
    end      

    result
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listVolumes, "volume", params).collect do |object|    
      return getVolume(object)
    end
  end
    
  def self.getVolume(object)       
    if object["name"] != nil  
      {        
        :id             => object["id"],
        :name           => object["name"],
        :diskofferingid => object["diskofferingid"],   
        :diskoffering   => object["diskofferingname"],  
        :snapshot       => object["snapshotid"],
        :zoneid         => object["zoneid"],
        :zone           => object["zonename"],     
        :account        => object["account"],
        :domain         => object["domain"],
        :domainid       => object["domainid"],
        :ensure         => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createVolume
    Puppet.debug "Create Volume "+resource[:name]
        
    zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id') 
    
    params = {
      :name         => resource[:name], 
      :zoneid       => zoneid,   
    }
    
    if resource[:diskoffering] != nil
      diskofferingid = self.class.genericLookup(:listDiskOfferings, 'diskoffering', 'name', resource[:diskoffering], {}, 'id')      
      params[:diskofferingid] = diskofferingid
    else
      params[:snapshotid] = resource[:snapshotid]
    end
    
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    
    Puppet.debug "createVolume PARAMS = "+params.inspect
    response = self.class.http_get('createVolume', params)
  end

  def deleteVolume
    Puppet.debug "Delete Volume "+resource[:name]
      
    id = lookupId
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteVolume PARAMS = "+params.inspect
    response = self.class.http_get('deleteVolume', params)           
  end 
  
  def lookupId
    volume = self.class.getObject(resource[:name])
    volume[:id]
  end    
end