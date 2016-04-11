require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_configuration).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Configuration"
  
  mk_resource_methods
  
  def flush       
    updateConfiguration
  end  

  def self.instances    
    result = Array.new     
    
    global = Array.new     
    list = get_objects(:listConfigurations, "configuration")
    if list != nil  
      list.each do |object|
         map = getConfiguration(object, '', 'global')
         if map != nil
           #Puppet.debug "Global Configuration: "+map.inspect
           global.push(new(map))
         end
      end
    end    
    
    list = get_objects(:listAccounts, "account", { :listall => true })     
    accounts = addConfigs(list, 'accountid')
      
    list = get_objects(:listClusters, "cluster")
    clusters = addConfigs(list, 'clusterid')
    
    list = get_objects(:listStoragePools, "storagepool")
    storage = addConfigs(list, 'storageid')
      
    list = get_objects(:listZones, "zone")
    zones = addConfigs(list, 'zoneid')
          
    result = global + accounts + clusters + storage + zones
      
    result 
  end
  
  def self.addConfigs(scopeObjects, idName)   
    result = Array.new      
     
    if scopeObjects != nil  
      scopeObjects.each do |scopeObject|
        scopeId = scopeObject["id"]
        scopeName = scopeObject["name"]
        
        params = { idName => scopeId }  
        list = get_objects(:listConfigurations, "configuration", params)
        if list != nil  
          list.each do |object|
            map = getConfiguration(object, scopeId, scopeName)
            if map != nil
              #Puppet.debug "Configuration: "+map.inspect
              result.push(new(map))
            end
          end 
        end 
      end
    end
    
    result 
  end

  def self.getConfiguration(object, scopeId, scopeName)   
    if object["name"] != nil 
      account = nil
      cluster = nil
      storage = nil      
      zone = nil
            
      case object["scope"]
        when 'account'
          account = scopeName
        when 'cluster'
          cluster = scopeName
        when 'storagepool'
          storage = scopeName
        when 'zone'
          zone = scopeName
      end
      
      if object["scope"] == nil
        name = 'global_'+object["name"]
      else
        name = object["scope"]+'_'+scopeName+'_'+object["name"]
      end
            
      {
        :name                  => name,
        :configuration_name    => object["name"],
        :value                 => object["value"],          
        :account               => account,
        :cluster               => cluster,
        :storage               => storage,
        :zone                  => zone,
        :ensure                => :present
      }
    end
  end

  # TYPE SPECIFIC    
  private
  def updateConfiguration
    Puppet.debug "Update Configuration "+resource[:name]
        
    params = {   
      :name            => resource[:configuration_name], 
      :value           => resource[:value], 
    }
    
    if resource[:account] != nil
      accountid = self.class.genericLookup(:listAccounts, 'account', 'name', resource[:account], { :listall => true }, 'id')
      params[:accountid] = accountid
    end
    
    if resource[:cluster] != nil
      clusterid = self.class.genericLookup(:listClusters, 'cluster', 'name', resource[:cluster], {}, 'id')  
      params[:clusterid] = clusterid
    end
    
    if resource[:storage] != nil
      storageid = self.class.genericLookup(:listStoragePools, 'storagepool', 'name', resource[:storage], {}, 'id')  
      params[:storageid] = storageid
    end
    
    if resource[:zone] != nil
      zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
      params[:zoneid] = zoneid
    end
      
    Puppet.debug "updateConfiguration PARAMS = "+params.inspect
    response = self.class.http_get('updateConfiguration', params)  
  end  
end