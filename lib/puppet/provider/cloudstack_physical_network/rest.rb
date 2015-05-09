require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_physical_network).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Physical Network"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :absent
      deletePhysicalNetwork
      return
    end 
    
    if @property_flush[:ensure] != :absent
      return if createPhysicalNetwork
    end
    
    if @property_flush[:ensure] == :enabled
      enablePhysicalNetwork
      return
    end 
        
    if @property_flush[:ensure] == :disabled
      disablePhysicalNetwork
      return
    end 
    
    updatePhysicalNetwork
  end  

  def self.instances
    list = get_objects(:listPhysicalNetworks, "physicalnetwork")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|    
      map = getPhysicalNetwork(object)
      if map != nil
        #Puppet.debug "Physical Network: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listPhysicalNetworks, "physicalnetwork", params).collect do |object|    
      return getPhysicalNetwork(object)
    end
  end
    
  def self.getPhysicalNetwork(object) 
    tags = convertCSVtoArray(object["tags"])
      
    zone = genericLookup(:listZones, 'zone', 'id', object["zoneid"], {}, 'name')
    domain = genericLookup(:listDomains, 'domain', 'id', object["domainid"], {}, 'name') unless object["domainid"] == nil
    
    if object["name"] != nil  
      {
        :id               => object["id"],
        :name             => object["name"],   
        :zoneid           => object["zoneid"],
        :zone             => zone, 
        :domainid         => object["domainid"],
        :domain           => domain,  
        :isolationmethods => object["isolationmethods"],
        :vlan             => object["vlan"], 
        :tags             => tags,
        :state            => object["state"].downcase,
        :ensure           => :present
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
  def createPhysicalNetwork
    if @property_hash.empty?            
      Puppet.debug "Create Physical Network "+resource[:name]
   
      zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
        
      params = {         
        :name               => resource[:name],   
        :zoneid             => zoneid,           
        :isolationmethods   => resource[:isolationmethods],   
        :vlan               => resource[:vlan],   
        :tags               => resource[:tags].join(","), 
      }
      
      if resource[:domain] != nil
        domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')
        params[:domainid] = domainid
      end
              
      Puppet.debug "createPhysicalNetwork PARAMS = "+params.inspect
      response = self.class.http_get('createPhysicalNetwork', params)
      self.class.wait_for_async_call(response["jobid"])
        
      true
    end
    
    false
  end

  def deletePhysicalNetwork
    Puppet.debug "Delete Physical Network "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deletePhysicalNetwork PARAMS = "+params.inspect
#    response = self.class.http_get('deletePhysicalNetwork', params)           
    
#    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updatePhysicalNetwork
    Puppet.debug "Update Physical Network "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
            
    if resource[:tags] != currentObject[:tags] or resource[:vlan] != currentObject[:vlan]
      id = lookupId
      params = { 
        :id      => id,   
        :vlan    => resource[:vlan],    
        :tags    => resource[:tags].join(","),  
      }
      Puppet.debug "updatePhysicalNetwork PARAMS = "+params.inspect
      response = self.class.http_get('updatePhysicalNetwork', params)    
     
      self.class.wait_for_async_call(response["jobid"])
    else 
      raise "Only tags and vlan can be updated for Physical Network !!!"  
    end
  end  
  
  def updateState(state)
    id = lookupId
    params = { 
      :id      => id,   
      :state   => state,
    }
    Puppet.debug "updatePhysicalNetwork PARAMS = "+params.inspect
      response = self.class.http_get('updatePhysicalNetwork', params)    
   
      self.class.wait_for_async_call(response["jobid"])
  end
  
  def enablePhysicalNetwork
    Puppet.debug "Enable Physical Network "+resource[:name]
      
    updateState("Enabled")
  end
  
  def disablePhysicalNetwork
    Puppet.debug "Disable Physical Network "+resource[:name]
      
    updateState("Disabled")    
  end
  
  def lookupId 
    return self.class.genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'name', resource[:name], {}, 'id')    
  end
end