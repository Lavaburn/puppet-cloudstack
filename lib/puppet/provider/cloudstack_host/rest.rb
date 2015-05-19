require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_host).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Host"
  
  mk_resource_methods
  
  def flush     
    if @property_flush[:ensure] == :absent
      deleteHost
      return
    end    
    
    if @property_flush[:ensure] != :absent
      return if createHost
    end
    
    if @property_flush[:ensure] == :enabled
      enableHost      
      return 
    end
        
    if @property_flush[:ensure] == :disabled
      disableHost
      return 
    end
    
    if @property_flush[:ensure] == :maintenance
      prepareMaintenance
      return 
    end
    
    updateHost
  end  

  def self.instances
    result = Array.new  
    
    list = get_objects(:listHosts, "host")
    if list != nil
      list.each do |object|
        map = getHost(object)
        if map != nil
          Puppet.debug "HOST FOUND: "+map.inspect
          result.push(new(map))
        end
      end       
    end      

    result
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listHosts, "host", params).collect do |object|    
      return getHost(object)
    end
  end
    
  def self.getHost(object)       
    if object["name"] != nil 
      tags = convertCSVtoArray(object["hosttags"])
       
      {
        :id           => object["id"],
        :name         => object["name"],
        :clustertype  => object["clustertype"],   
        :hypervisor   => object["hypervisor"],
        :zoneid       => object["zoneid"],
        :zone         => object["zonename"],     
        :podid        => object["podid"],
        :pod          => object["podname"],    
        :clusterid    => object["clusterid"],
        :cluster      => object["clustername"],  
        :tags         => tags,  
        :state        => object["resourcestate"].downcase, 
        :ensure       => :present
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
  def createHost
    if @property_hash.empty?  
      Puppet.debug "Create Host "+resource[:name]
          
      zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
      podid = self.class.genericLookup(:listPods, 'pod', 'name', resource[:pod], {}, 'id')  
      clusterid = self.class.genericLookup(:listClusters, 'cluster', 'name', resource[:cluster], {}, 'id')  
      
      params = {
        :url          => "http://"+resource[:ipaddress],
        :username     => resource[:username],
        :password     => resource[:password],
        :hypervisor   => resource[:hypervisor],
        :clusterid    => clusterid,
        # :clustername ???   
        :podid        => podid,   
        :zoneid       => zoneid,   
        :hosttags     => resource[:tags].join(','),
      }
      Puppet.debug "addHost PARAMS = "+params.inspect
      response = self.class.http_get('addHost', params)
      
      return true
    end
      
    false
  end

  def deleteHost
    Puppet.debug "Delete Host "+resource[:name]
      
    id = lookupId
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteHost PARAMS = "+params.inspect
    response = self.class.http_get('deleteHost', params)           
  end
  
  def updateHost
    Puppet.debug "Update Host "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:tags] != currentObject[:tags]
      id = lookupId
      params = { 
        :id       => id,   
        :hosttags => resource[:tags].join(","),  
      }
      Puppet.debug "updateHost PARAMS = "+params.inspect
      response = self.class.http_get('updateHost', params)   
    else 
      raise "Only tags can be updated for Host !"  
    end   
  end  
  
  def updateAllocationState(state)
    id = lookupId
    params = { 
       :id              => id,
       :allocationstate => state,
    }
    
    Puppet.debug "updateHost PARAMS = "+params.inspect
    response = self.class.http_get('updateHost', params)
  end
  
  def disableHost
    Puppet.debug "Disable Host "+resource[:name]
      
    currentState = getState
    if currentState == "prepareformaintenance" or  currentState == "maintenance"
      raise "The host #{resource[:name]} is currently in maintenance mode. You can not disable it!"
    end
      
    updateAllocationState('Disable')  
  end

  def enableHost
    Puppet.debug "Enable Host "+resource[:name]
      
    currentState = getState
    if currentState == "prepareformaintenance" or  currentState == "maintenance"
      cancelMaintenance
    else
      updateAllocationState('Enable')
    end
  end
  
  def prepareMaintenance
    Puppet.debug "Prepare Host for Maintenance "+resource[:name]
      
    currentState = getState
    if currentState == "disabled"
      raise "The host #{resource[:name]} is currently disabled. You can not put it in maintenance mode!"
    end
      
    id = lookupId
    params = { 
       :id => id,
    }
    
    Puppet.debug "prepareHostForMaintenance PARAMS = "+params.inspect
    response = self.class.http_get('prepareHostForMaintenance', params)
    self.class.wait_for_async_call(response["jobid"])    
  end
  
  def cancelMaintenance
    Puppet.debug "Cancel Host Maintenance "+resource[:name]
    
    id = lookupId
    params = { 
       :id => id,
    }
    
    Puppet.debug "cancelHostMaintenance PARAMS = "+params.inspect
    response = self.class.http_get('cancelHostMaintenance', params)
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def lookupId   
    cluster = self.class.getObject(resource[:name])
    cluster[:id]
  end    
end