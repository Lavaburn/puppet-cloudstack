require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_traffic_type).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Traffic Type"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createTrafficType
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteTrafficType
      return
    end 

    updateTrafficType
  end  

  def self.instances    
    result = Array.new  

    networks = get_objects(:listPhysicalNetworks, "physicalnetwork")
    if networks != nil
      networks.each do |network|    
        list = get_objects(:listTrafficTypes, "traffictype", { :physicalnetworkid => network['id'] })
        if list != nil
          list.each do |object|    
            map = getTrafficType(object)
            if map != nil
              #Puppet.debug "Traffic Type: "+map.inspect
              result.push(new(map))
            end
          end
        end
      end 
    end

    result
  end
  
  def self.getObject(physicalnetworkid, traffictype)    
    params = { :physicalnetworkid => physicalnetworkid }
    types = get_objects(:listTrafficTypes, "traffictype", params)
    if types != nil
      types.each do |object|    
        if object['traffictype'] == traffictype
          return getTrafficType(object)
        end
      end
    end  
    
    raise "Could not find traffic type #{traffictype} for network "+physicalnetworkid 
  end
    
  def self.getTrafficType(object)     
    if object["id"] != nil  
      physicalNetwork = genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'id', object["physicalnetworkid"], {}, 'name')
        
      {
        :id                 => object["id"],
        :name               => physicalNetwork+"_"+object["traffictype"],
        :physicalnetwork    => physicalNetwork,
        :traffictype        => object["traffictype"],
        :hypervnetworklabel => object["hypervnetworklabel"],
        :kvmnetworklabel    => object["kvmnetworklabel"],
        :vmwarenetworklabel => object["vmwarenetworklabel"],
        :xennetworklabel    => object["xennetworklabel"],
        :ensure             => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createTrafficType
    Puppet.debug "Create Traffic Type "+resource[:name]
 
    physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'name', resource[:physicalnetwork], {}, 'id')
        
    params = {         
      :physicalnetworkid  => physicalnetworkid,
      :traffictype        => resource[:traffictype],   
      :isolationmethod    => resource[:isolationmethod],   
      :hypervnetworklabel => resource[:hypervnetworklabel],    
      :kvmnetworklabel    => resource[:kvmnetworklabel],    
      :vmwarenetworklabel => resource[:vmwarenetworklabel],    
      :xennetworklabel    => resource[:xennetworklabel],
    }
                
    Puppet.debug "addTrafficType PARAMS = "+params.inspect
    response = self.class.http_get('addTrafficType', params)
    
    self.class.wait_for_async_call(response["jobid"])
  end

  def deleteTrafficType
    Puppet.debug "Delete Traffic Type "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deleteTrafficType PARAMS = "+params.inspect
    response = self.class.http_get('deleteTrafficType', params)           
    
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updateTrafficType
    Puppet.debug "Update Traffic Type "+resource[:name]
      
    physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'name', @property_hash[:physicalnetwork], {}, 'id')
      
    currentObject = self.class.getObject(physicalnetworkid, @property_hash[:traffictype])
            
    if (resource[:hypervnetworklabel] != currentObject[:hypervnetworklabel] or 
        resource[:kvmnetworklabel] != currentObject[:kvmnetworklabel] or
        resource[:vmwarenetworklabel] != currentObject[:vmwarenetworklabel] or 
        resource[:xennetworklabel] != currentObject[:xennetworklabel])
      id = lookupId
      
      params = { 
        :id                 => id,     
        :hypervnetworklabel => resource[:hypervnetworklabel],    
        :kvmnetworklabel    => resource[:kvmnetworklabel],    
        :vmwarenetworklabel => resource[:vmwarenetworklabel],    
        :xennetworklabel    => resource[:xennetworklabel],          
      }
      Puppet.debug "updateTrafficType PARAMS = "+params.inspect
      response = self.class.http_get('updateTrafficType', params)    
     
      self.class.wait_for_async_call(response["jobid"])
    else 
      raise "Only labels can be updated for Traffic Type !!!"  
    end
  end  
  
  def lookupId 
    physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'name', resource[:physicalnetwork], {}, 'id')        
    object = self.class.getObject(physicalnetworkid, resource[:traffictype])
    return object[:id]
  end
end