require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_zone).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Zone"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :absent
      deleteZone
      return
    end    
    
    if @property_flush[:ensure] != :absent
      return if createZone
    end
    
    if @property_flush[:ensure] == :enabled
      enableZone
      return 
    end
        
    if @property_flush[:ensure] == :disabled
      disableZone
      return 
    end
    
    updateZone
  end  

  def self.instances
    list = get_objects(:listZones, "zone")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getZone(object)
      if map != nil
        #Puppet.debug "ZONE FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listZones, "zone", params).collect do |object|    
      return getZone(object)
    end
  end
    
  def self.getZone(object)   
    if object["name"] != nil  
      {
        :id               => object["id"],
        :name             => object["name"],   
        :networktype      => object["networktype"],   
        :dns1             => object["dns1"],   
        :dns2             => object["dns2"],   
        :internaldns1     => object["internaldns1"],   
        :internaldns2     => object["internaldns2"],   
        :networkdomain    => object["domain"],     
        :guestcidraddress => object["guestcidraddress"],   
        :state            => object["allocationstate"].downcase, 
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
  def createZone    
    if @property_hash.empty?  
      Puppet.debug "Create Zone "+resource[:name]
        
      params = {         
        :name             => resource[:name],   
        :networktype      => resource[:networktype],   
        :dns1             => resource[:dns1],   
        :dns2             => resource[:dns2],   
        :internaldns1     => resource[:internaldns1],   
        :internaldns2     => resource[:internaldns2],   
        :guestcidraddress => resource[:guestcidraddress],   
      }
      
      # Optional parameters     
      if resource[:networkdomain] != nil
        params[:domain] = resource[:networkdomain]
      end
      
      #Puppet.debug "createZone PARAMS = "+params.inspect
      response = self.class.http_get('createZone', params)
      
      return true
    end
    
    return false
  end

  # BUG in 4.4.3 - The zone is not deletable because there are servers running in this zone
  def deleteZone
    Puppet.debug "Delete Zone "+resource[:name]
      
    id = lookupId
      
    params = { 
      :id => id,
    }
    #Puppet.debug "deleteZone PARAMS = "+params.inspect
    response = self.class.http_get('deleteZone', params)           
  end
  
  def updateZone
    Puppet.debug "Update Zone "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:networktype] != currentObject[:networktype]
      raise "Zone Network Type (Basic/Advanced) can not be altered after creation! (Zone = "+resource[:name]+")"
    end
    
    id = lookupId
    params = { 
      :id               => id,# Puppet links name to ID, so changing name is not possible !      
      :dns1             => resource[:dns1],   
      :dns2             => resource[:dns2],   
      :internaldns1     => resource[:internaldns1],   
      :internaldns2     => resource[:internaldns2],   
      :guestcidraddress => resource[:guestcidraddress], 
    }
    
    # Optional parameters     
    if resource[:networkdomain] != nil
      params[:domain] = resource[:networkdomain]
    end
    
    #Puppet.debug "updateZone PARAMS = "+params.inspect
    response = self.class.http_get('updateZone', params)    
  end  
  
  def updateAllocationState(state)
    id = lookupId
    params = { 
       :id              => id,
       :allocationstate => state,
    }

    #Puppet.debug "updateZone PARAMS = "+params.inspect
    response = self.class.http_get('updateZone', params)  
  end
  
  def disableZone
    Puppet.debug "Disable Zone "+resource[:name]      
    updateAllocationState('Disabled')  
  end

  def enableZone
    Puppet.debug "Enable Zone "+resource[:name]
    updateAllocationState('Enabled')  
  end
  
  def lookupId
    zone = self.class.getObject(resource[:name])
    
    zone[:id]
  end
end