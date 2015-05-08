require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_network_offering).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Network Offering"
  
  mk_resource_methods
  
  def flush      
    if @property_flush[:ensure] == :absent
      deleteNetworkOffering
      return
    end 
        
    if @property_flush[:ensure] != :absent
      return if createNetworkOffering
    end
        
    if @property_flush[:ensure] == :enabled
      enableNetworkOffering
      return
    end 
    
#    if @property_flush[:ensure] == :inactive
#      # ???
#      return
#    end 
    
    if @property_flush[:ensure] == :disabled
      disableNetworkOffering
      return
    end 
    
    updateNetworkOffering
  end  

  def self.instances     
    list = get_objects(:listNetworkOfferings, "networkoffering")
    if list == nil
      return list
    end
    
    result = Array.new  
    list.each do |object|
      map = getNetworkOffering(object)
      if map != nil
        #Puppet.debug "NetworkOffering FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    
    #Puppet.debug "LOOKUP NetworkOffering: "+params.inspect

    list = get_objects(:listNetworkOfferings, "networkoffering", params)    
    if list == nil
      raise "Could not find Network Offering with name "+name
    end
    
    list.each do |object|   
       if object["name"] == name
         #Puppet.debug "NetworkOffering FOUND (2): "+object.inspect
         return getNetworkOffering(object)         
       end      
    end
    
    # Found similar names, but no exact matches!
    return nil
  end
    
  def self.getNetworkOffering(object)   
    if object["name"] != nil        
      tags = convertCSVtoArray(object["tags"])
  
      params = { :id => object['serviceofferingid'] }
      serviceoffering = getServiceOffering(params)
              
      {
        :id                   => object["id"],
        :name                 => object["name"],   
        :displaytext          => object["displaytext"],            
        :guestiptype          => object["guestiptype"].downcase,
        :ispersistent         => object["ispersistent"],
        :conservemode         => object["conservemode"],     
        :availability         => object["availability"],
        :specifyvlan          => object["specifyvlan"],
        :specifyipranges      => object["specifyipranges"],            
        :egressdefaultpolicy  => object["egressdefaultpolicy"],          
        :serviceoffering      => serviceoffering["name"],        
        :service              => object["service"],
        :tags                 => tags,  
        :state                => object["state"].downcase,
        :ensure               => :present
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
  def createNetworkOffering
    if @property_hash.empty?      
      Puppet.debug "Create NetworkOffering "+resource[:name]
        
      if resource[:tags] == nil
        tags = nil
      else
        tags = resource[:tags].join(",")
      end
  
      params = { :name => resource[:serviceoffering] }
      serviceoffering = self.class.getServiceOffering(params)
        
      supportedservices = Array.new
      resource[:service].each do | serviceDesc |            
        supportedservices.push(serviceDesc["name"])
      end
  
      params = {         
        :name                 => resource[:name],   
        :displaytext          => resource[:displaytext],   
        :guestiptype          => resource[:guestiptype].downcase,   
        :ispersistent         => resource[:ispersistent],   
        :conservemode         => resource[:conservemode], 
        :availability         => resource[:availability], 
        :specifyvlan          => resource[:specifyvlan],         
        :specifyipranges      => resource[:specifyipranges], 
        :egressdefaultpolicy  => resource[:egressdefaultpolicy],   
        :serviceofferingid    => serviceoffering["id"],
        :tags                 => tags,  
        :supportedservices    => supportedservices.join(","),
        # :servicecapabilitylist ???
        :traffictype          => 'Guest',      
      }
  
      index = 0
      resource[:service].each do | serviceDesc |
        params["serviceproviderlist[#{index}].service"] = serviceDesc["name"]
        serviceDesc["provider"].each do | provider |
          params["serviceproviderlist[#{index}].provider"] = provider["name"]
        end
              
        index += 1
      end
      
      Puppet.debug "createNetworkOffering PARAMS = "+params.inspect
      response = self.class.http_get('createNetworkOffering', params)
      
      return true
    end
    
    false
  end

  def deleteNetworkOffering
    Puppet.debug "Delete NetworkOffering "+resource[:name]
      
    id = lookupNetworkOfferingId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteNetworkOffering PARAMS = "+params.inspect
    response = self.class.http_get('deleteNetworkOffering', params)           
  end
  
  def updateNetworkOffering
    Puppet.debug "Update NetworkOffering "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:displaytext] != currentObject[:displaytext]
      id = lookupNetworkOfferingId(resource[:name])
      params = { 
        :id          => id,# Puppet links name to ID, so changing name is not possible !
        :displaytext => resource[:displaytext],   
      }
                  
      Puppet.debug "updateNetworkOffering PARAMS = "+params.inspect
      response = self.class.http_get('updateNetworkOffering', params)  
    else
      raise "Settings for NetworkOffering can not be updated! Only displaytext can be changed."
    end  
  end  
  
  def enableNetworkOffering
    Puppet.debug "Enable Network Offering "+resource[:name]
    
    updateState("Enabled")      
  end
  
  def disableNetworkOffering
    Puppet.debug "Disable Network Offering "+resource[:name]
      
    updateState("Disabled")      
  end
  
  def updateState(state)
    id = lookupNetworkOfferingId(resource[:name])
    params = {       
      :id     => id,
      :state  => state,
    }
    
    Puppet.debug "updateNetworkOffering PARAMS = "+params.inspect
    response = self.class.http_get('updateNetworkOffering', params)    
  end
    
  def lookupNetworkOfferingId(name) 
    networkOffering = self.class.getObject(name)
    
    networkOffering[:id]
  end
  
  def self.getServiceOffering(params)    
    params[:issystem] = true
    list = get_objects(:listServiceOfferings, "serviceoffering", params)
    if list != nil        
      list.collect do |object|    
        return object
      end
    end

    raise "Service Offering does not exist. Params = "+params.inspect
  end
end