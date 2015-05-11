require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_primary_storage).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Primary Storage"
  
  mk_resource_methods
  
  def flush       
    if @property_flush[:ensure] == :absent
      deletePrimaryStorage
      return
    end
     
    if @property_flush[:ensure] != :absent
      return if createPrimaryStorage
    end 

    if @property_flush[:ensure] == :maintenance
      enableMaintenance
      return 
    end

    if @property_flush[:ensure] == :up
      cancelMaintenance
      return 
    end
    
    updatePrimaryStorage
  end  

  def self.instances
    list = get_objects(:listStoragePools, "storagepool")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getPrimaryStorage(object)
      if map != nil
        #Puppet.debug "Storage Pool (Primary Storage): "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listStoragePools, "storagepool", params).collect do |object|    
      return getPrimaryStorage(object)
    end
  end
    
  def self.getPrimaryStorage(object) 
    tags = convertCSVtoArray(object["tags"])
    
    if object["name"] != nil  
      {
        :id               => object["id"],
        :name             => object["name"],             
        :scope            => object["scope"].downcase,  
        :zoneid           => object["zoneid"],
        :zone             => object["zonename"], 
        :podid            => object["podid"],
        :pod              => object["podname"],  
        :clusterid        => object["clusterid"],
        :cluster          => object["clustername"], 
        :hypervisor       => object["hypervisor"],   
        :url              => object["type"]+"://"+object["ipaddress"]+object["path"],
        :tags             => tags.sort,
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
  def createPrimaryStorage
    if @property_hash.empty?  
      Puppet.debug "Create Primary Storage "+resource[:name]
   
      zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
        
      params = {         
        :name    => resource[:name],   
        :scope   => resource[:scope],   
        :url     => resource[:url],   
        :zoneid  => zoneid,     
        :tags    => resource[:tags].join(","), 
      }
      
      if resource[:pod] != nil
        podid = self.class.genericLookup(:listPods, 'pod', 'name', resource[:pod], {}, 'id')      
        params[:podid] = podid
      end
      
      if resource[:cluster] != nil
        clusterid = self.class.genericLookup(:listClusters, 'cluster', 'name', resource[:cluster], {}, 'id')      
        params[:clusterid] = clusterid
      end
      
      if resource[:hypervisor] != nil
        params[:provider] = resource[:provider]
      end
          
      Puppet.debug "createStoragePool PARAMS = "+params.inspect
      response = self.class.http_get('createStoragePool', params)
      
      return true
    end
    
    false
  end

  def deletePrimaryStorage
    Puppet.debug "Delete Primary Storage "+resource[:name]
      
    currentState = getState
    if currentState == "prepareformaintenance" or  currentState == "maintenance"
      id = lookupId
           
      params = { 
        :id => id,
      }
      Puppet.debug "deleteStoragePool PARAMS = "+params.inspect
      response = self.class.http_get('deleteStoragePool', params)           
    else
      raise "Primary Storage can only be deleted when in Maintenance Mode!"
    end
  end
  
  def updatePrimaryStorage
    Puppet.debug "Update Primary Storage "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
            
    if resource[:tags] != currentObject[:tags]
      id = lookupId
      params = { 
        :id      => id,
        :tags    => resource[:tags].join(","),          
      }
      Puppet.debug "updateStoragePool PARAMS = "+params.inspect
      response = self.class.http_get('updateStoragePool', params)    
    else 
      raise "Only tags can be updated for Primary Storage !!!"  
    end
  end
  
  def enableMaintenance
    Puppet.debug "Enable Maintenance on Primary Storage "+resource[:name]
      
    id = lookupId
    params = { 
      :id      => id,
    }
    Puppet.debug "enableStorageMaintenance PARAMS = "+params.inspect
    response = self.class.http_get('enableStorageMaintenance', params)    
    self.class.wait_for_async_call(response["jobid"])        
  end
  
  def cancelMaintenance
    Puppet.debug "Cancel Maintenance on Primary Storage "+resource[:name]
          
    id = lookupId
    params = { 
      :id      => id,
    }
    Puppet.debug "cancelStorageMaintenance PARAMS = "+params.inspect
    response = self.class.http_get('cancelStorageMaintenance', params)    
    self.class.wait_for_async_call(response["jobid"])        
  end
  
  def lookupId 
    return self.class.genericLookup(:listStoragePools, 'storagepool', 'name', resource[:name], {}, 'id')    
  end
end