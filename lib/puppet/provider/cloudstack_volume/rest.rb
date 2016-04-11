require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_volume).provide :rest, :parent => Puppet::Provider::CloudstackRest do
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
    
    return if attachVolume

    raise "Update volume is currently not implemented. Not much to do anyway..."
  end  

  def self.instances
    result = Array.new  
    
    list = get_objects(:listVolumes, "volume", { :listall => true })
    if list != nil
      list.each do |object|
        map = getVolume(object)
        if map != nil
          #Puppet.debug "VOLUME FOUND: "+map.inspect
          result.push(new(map))
        end
      end       
    end      

    result
  end
  
  def self.getObject(name) 
    params = { :name => name, :listall => true }
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
        :virtualmachine => object["vmname"],
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
    
    if resource[:virtualmachine] != nil
      virtualmachineid = self.class.genericLookup(:listVirtualMachines, 'virtualmachine', 'name', resource[:virtualmachine], { :listall => true }, 'id')
      params[:virtualmachineid] = virtualmachineid
    end
    
    #Puppet.debug "createVolume PARAMS = "+params.inspect
    response = self.class.http_get('createVolume', params)
    self.class.wait_for_async_call(response["jobid"])    
  end

  def deleteVolume
    Puppet.debug "Delete Volume "+resource[:name]
      
    id = lookupId
      
    params = { 
      :id => id,
    }
    #Puppet.debug "deleteVolume PARAMS = "+params.inspect
    response = self.class.http_get('deleteVolume', params)           
  end 
  
  def attachVolume
    currentObject = self.class.getObject(@property_hash[:name])
    
    if currentObject[:virtualmachine] != resource[:virtualmachine]      
      if currentObject[:virtualmachine] != nil
        Puppet.debug "Detaching Volume "+resource[:name]+" from "+currentObject[:virtualmachine] 
          
        id = lookupId
        virtualmachineid = self.class.genericLookup(:listVirtualMachines, 'virtualmachine', 'name', currentObject[:virtualmachine], { :listall => true }, 'id')
          
        params = { 
          :id               => id,
          :virtualmachineid => virtualmachineid,
        }
         
        #Puppet.debug "detachVolume PARAMS = "+params.inspect
        response = self.class.http_get('detachVolume', params)
        self.class.wait_for_async_call(response["jobid"])              
      end
      
      if resource[:virtualmachine]  != nil
        Puppet.debug "Attaching Volume "+resource[:name]+" to "+resource[:virtualmachine] 
          
        id = lookupId
        virtualmachineid = self.class.genericLookup(:listVirtualMachines, 'virtualmachine', 'name', resource[:virtualmachine], { :listall => true }, 'id')
          
        params = { 
          :id               => id,
          :virtualmachineid => virtualmachineid,
        }
        
        if resource[:device] != nil
          params[:deviceid] = self.class.volumes.key(resource[:device])
        end
              
        #Puppet.debug "attachVolume PARAMS = "+params.inspect
        response = self.class.http_get('attachVolume', params)
        self.class.wait_for_async_call(response["jobid"])    
      end   
       
      return true      
    end
    
    return false    
  end
  
  def lookupId
    volume = self.class.getObject(resource[:name])
    volume[:id]
  end    
  
  def self.volumes
    {
      0 => '/dev/xvda',
      1 => '/dev/xvdb',
      2 => '/dev/xvdc',
      3 => '/dev/xvdd',
      4 => '/dev/xvde',
      5 => '/dev/xvdf',
      6 => '/dev/xvdg',
      7 => '/dev/xvdh',
      8 => '/dev/xvdi',
      9 => '/dev/xvdj',
    }
  end
end