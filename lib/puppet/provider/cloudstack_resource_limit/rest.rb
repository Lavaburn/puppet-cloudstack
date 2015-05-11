require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_resource_limit).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Resource Limit"
  
  mk_resource_methods
  
  def flush       
    updateConfiguration
  end  

  def self.instances    
    result = Array.new     
    
    list = get_objects(:listDomains, "domain")
    domains = addConfigs(list, { 'domainid' => 'id' })
    
    list = get_objects(:listAccounts, "account", { :listall => true })     
    accounts = addConfigs(list, { 'domainid' => 'domainid', 'account' => 'name' })
 
    result = domains + accounts
    
    result 
  end
  
  def self.addConfigs(scopeObjects, lookupParams)   
    result = Array.new
         
    if scopeObjects != nil  
      scopeObjects.each do |scopeObject|
        params = Hash.new
        
        lookupParams.each do |lookup, scopeId|
          params[lookup] = scopeObject[scopeId]
        end
        
        list = get_objects(:listResourceLimits, "resourcelimit", params)
        if list != nil  
          list.each do |object|
            map = getResourceLimit(object)
            if map != nil
              #Puppet.debug "Resource Limit FOUND: "+map.inspect
              result.push(new(map))
            end
          end 
        end 
      end
    end

    result
  end
  
  def self.getResourceLimit(object)   
    if object["resourcetype"] != nil                         
      type = resourceTypes.fetch(object["resourcetype"].to_i)

      if object["account"] == nil
        name = type+"_"+object["domain"]
      else
        name = type+"_"+object["account"]+'@'+object["domain"]
      end
              
      {
        :name           => name,
        :type           => type,
        :account        => object["account"],    
        :domainid       => object["domainid"],   
        :domain         => object["domain"],   
        :max            => object["max"].to_s,   
#        :projectid      => object["projectid"],   
#        :project        => object["project"],   
        :ensure         => :present
      }
    end
  end

  # TYPE SPECIFIC    
  private
  def updateConfiguration
    Puppet.debug "Update Configuration "+resource[:name]
      
    resourcetype = self.class.resourceTypes.key(resource[:type])
        
    params = {   
      :resourcetype   => resourcetype.to_s,
      :max            => resource[:max], 
    }
    
    if resource[:domain] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')      
      params[:domainid] = domainid
    end   
    
    if resource[:account] != nil    
      params[:account] = resource[:account]
    end   
      
    Puppet.debug "updateResourceLimit PARAMS = "+params.inspect
    response = self.class.http_get('updateResourceLimit', params)  
  end  
  
  def self.resourceTypes
    {
      0 => "instance",
      1 => "ip",
      2 => "volume",
      3 => "snapshot",
      4 => "template",
      5 => "project",
      6 => "network",
      7 => "vpc",
      8 => "cpu",
      9 => "memory",
      10 => "primarystorage",
      11 => "secondarystorage",
    }
  end
end