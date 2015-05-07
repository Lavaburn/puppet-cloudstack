require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_pod).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Pod"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createPod
      return
    end
    
    if @property_flush[:ensure] == :absent
      deletePod
      return
    end 

    updatePod
  end  

  def self.instances
    list = get_objects(:listPods, "pod")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getPod(object)
      if map != nil
        #Puppet.debug "POD FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listPods, "pod", params).collect do |object|    
      return getPod(object)
    end
  end
    
  def self.getPod(object)   
    zone_params = { "id" => object["zoneid"] }     
    zone = getZone(zone_params)
    
    if object["name"] != nil  
      {
        :id               => object["id"],
        :name             => object["name"],   
        :zoneid           => object["zoneid"],
        :zone             => zone["name"],          
        :startip          => object["startip"],   
        :endip            => object["endip"],   
        :netmask          => object["netmask"],   
        :gateway          => object["gateway"],   
        :ensure           => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createPod
    Puppet.debug "Create Pod "+resource[:name]
        
    zone_params = { "name" => resource[:zone] }
    zone = self.class.getZone(zone_params) 
      
    params = {         
      :name    => resource[:name],   
      :zoneid  => zone["id"],   
      :startip => resource[:startip],   
      :endip   => resource[:endip],   
      :netmask => resource[:netmask],   
      :gateway => resource[:gateway],   
    }
    Puppet.debug "createPod PARAMS = "+params.inspect
    response = self.class.http_get('createPod', params)
  end

  def deletePod
    Puppet.debug "Delete Pod "+resource[:name]
      
    id = lookupPodId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deletePod PARAMS = "+params.inspect
    response = self.class.http_get('deletePod', params)           
  end
  
  def updatePod
    Puppet.debug "Update Pod "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:zone] != currentObject[:zone]
      raise "Pod can not be re-allocated to another zone after creation! (Pod = "+resource[:name]+")"
    end
    
    id = lookupPodId(resource[:name])
    params = { 
      :id      => id,# Puppet links name to ID, so changing name is not possible !      
      :startip => resource[:startip],   
      :endip   => resource[:endip],   
      :netmask => resource[:netmask],   
      :gateway => resource[:gateway],  
    }
    Puppet.debug "updatePod PARAMS = "+params.inspect
    response = self.class.http_get('updatePod', params)    
  end  
  
  def lookupPodId(name) 
    pod = self.class.getObject(name)
    
    pod[:id]
  end
  
  def self.getZone(params)
    list = get_objects(:listZones, "zone", params)        
    if list != nil        
      list.each do |object|    
        return object
      end
    end

    raise "Zone does not exist. "+params.inspect
  end        
end