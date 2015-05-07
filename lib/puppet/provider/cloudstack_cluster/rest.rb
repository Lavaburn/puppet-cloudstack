require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_cluster).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Cluster"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createCluster
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteCluster
      return
    end 

    updateCluster
  end  

  def self.instances
    list = get_objects(:listClusters, "cluster")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getCluster(object)
      if map != nil
        Puppet.debug "CLUSTER FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listClusters, "cluster", params).collect do |object|    
      return getCluster(object)
    end
  end
    
  def self.getCluster(object)       
    if object["name"] != nil  
      {
        :id           => object["id"],
        :name         => object["name"],
        :clustertype  => object["clustertype"],   
        :hypervisor   => object["hypervisortype"],
        :zoneid       => object["zoneid"],
        :zone         => object["zonename"],     
        :podid        => object["podid"],
        :pod          => object["podname"],    
        :ensure       => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createCluster
    Puppet.debug "Create Cluster "+resource[:name]
        
    zone_params = { "name" => resource[:zone] }
    zone = getZone(zone_params) 
    
    pod_params = { "name" => resource[:pod] }     
    pod = getPod(pod_params)
          
    params = {
      :clustername  => resource["name"],
      :clustertype  => resource["clustertype"],   
      :hypervisor   => resource["hypervisor"],
      :zoneid       => zone["id"],
      :podid        => pod["id"],       
    }
    Puppet.debug "addCluster PARAMS = "+params.inspect
    response = self.class.http_get('addCluster', params)
  end

  def deleteCluster
    Puppet.debug "Delete Cluster "+resource[:name]
      
    id = lookupClusterId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteCluster PARAMS = "+params.inspect
    response = self.class.http_get('deleteCluster', params)           
  end
  
  def updateCluster
    Puppet.debug "Update Cluster "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:zone] != currentObject[:zone]
      raise "Cluster can not be re-allocated to another zone after creation! (Cluster = "+resource[:name]+")"
    end
    if resource[:pod] != currentObject[:pod]
      raise "Cluster can not be re-allocated to another pod after creation! (Cluster = "+resource[:name]+")"
    end
        
    id = lookupClusterId(resource[:name])
    params = { 
      :id          => id,# Puppet links name to ID, so changing name is not possible !      
      :clustertype => resource[:clustertype],   
      :hypervisor  => resource[:hypervisor],   
    }
    Puppet.debug "updateCluster PARAMS = "+params.inspect
    response = self.class.http_get('updateCluster', params)    
  end  
  
  def lookupClusterId(name) 
    cluster = self.class.getObject(name)
    
    cluster[:id]
  end
  
  def getZone(params)
    list = self.class.get_objects(:listZones, "zone", params)        
    if list != nil        
      list.each do |object|    
        return object
      end
    end

    raise "Zone does not exist. "+params.inspect
  end   
  
  def getPod(params)
    list = self.class.get_objects(:listPods, "pod", params)        
    if list != nil        
      list.each do |object|    
        return object
      end
    end

    raise "Pod does not exist. "+params.inspect
  end        
end