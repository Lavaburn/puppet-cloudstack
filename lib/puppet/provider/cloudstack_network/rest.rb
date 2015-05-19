require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_network).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack (Guest) Network"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createNetwork
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteNetwork
      return
    end 
    
    updateNetwork
  end  

  def self.instances
    result = Array.new  
    
    list = get_objects(:listNetworks, "network", { :listall => true })
    if list != nil
      list.each do |object|    
        map = getNetwork(object)
        if map != nil
          Puppet.debug "Network Found: "+map.inspect
          result.push(new(map))
        end
      end   
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :listall => true, :name => name }
    get_objects(:listNetworks, "network", params).each do |object|    
      return getNetwork(object)
    end
  end
    
  def self.getNetwork(object)             
    physicalnetwork = nil  
    if object["physicalnetworkid"] != nil
      physicalnetwork = genericLookup(:listPhysicalNetworks, "physicalnetwork", 'id', object["physicalnetworkid"], {}, 'name')
    end
    
    if object["name"] != nil  
      {
        :id               => object["id"],
        :name             => object["name"],   
        :displaytext      => object["displaytext"],   
        :gateway          => object["gateway"],   
        :netmask          => object["netmask"],            
        :networkoffering  => object["networkofferingname"], 
        :zone             => object["zonename"],
        :physicalnetwork  => physicalnetwork,
        :vlan             => object["vlan"],  
        #:startip          => object[""],  
        #:endip            => object[""],  
        :account          => object["account"],
        :domain           => object["domain"],
        :networkdomain    => object["networkdomain"],    
        :tags             => object["tags"],
        :state            => object["state"].downcase, # "Setup"
        :ensure           => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createNetwork
    Puppet.debug "Create Network "+resource[:name]
 
    zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
    networkofferingid = self.class.genericLookup(:listNetworkOfferings, "networkoffering", 'name', resource[:networkoffering], { :listall => true }, 'id')
      
    params = {         
      :name               => resource[:name],   
      :displaytext        => resource[:displaytext],  
      :networkofferingid  => networkofferingid,        
      :zoneid             => zoneid,        
      :vlan               => resource[:vlan],  
      :startip            => resource[:startip],  
      :endip              => resource[:endip],  
      :netmask            => resource[:netmask],  
      :gateway            => resource[:gateway],        
      :networkdomain      => resource[:networkdomain],
    }
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    
    if resource[:physicalnetwork] != nil
      # ONLY FOR type Shared      
      physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, "physicalnetwork", 'name', resource[:physicalnetwork], {}, 'id')
      params[:physicalnetworkid] = physicalnetworkid
    end
            
    Puppet.debug "createNetwork PARAMS = "+params.inspect
    response = self.class.http_get('createNetwork', params)
  end

  def deleteNetwork
    Puppet.debug "Delete Network "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deleteNetwork PARAMS = "+params.inspect
    response = self.class.http_get('deleteNetwork', params)
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updateNetwork
    Puppet.debug "Update Network "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    update = false
    if resource[:displaytext] != currentObject[:displaytext]
      update = true
    end
    if resource[:networkdomain] != currentObject[:networkdomain]
      update = true
    end
    if resource[:networkoffering] != currentObject[:networkoffering]
      update = true
    end
        
    if update
      id = lookupId
      networkofferingid = self.class.genericLookup(:listNetworkOfferings, "networkoffering", 'name', resource[:networkoffering], { :listall => true }, 'id')
      
      params = { 
        :id      => id,   
        :displaytext        =>  resource[:displaytext],    
        :networkdomain      => resource[:networkdomain],  
        :networkofferingid  => networkofferingid,          
      }
      Puppet.debug "updateNetwork PARAMS = "+params.inspect
      response = self.class.http_get('updateNetwork', params)    
      self.class.wait_for_async_call(response["jobid"])
    else 
      raise "On Guest Network, the API only allows updating of: displaytext, networkdomain, networkoffering !"  
    end
  end  
  
  def lookupId
    return self.class.genericLookup(:listNetworks, 'network', 'name', resource[:name], { :listall => true }, 'id')
  end
end