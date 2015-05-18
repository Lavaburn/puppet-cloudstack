require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_domain).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Domain"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createDomain
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteDomain
      return
    end 

    updateDomain
  end  

  def self.instances
    list = get_objects(:listDomains, "domain")
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getDomain(object)
      if map != nil
        #Puppet.debug "DOMAIN FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
      
    list = get_objects(:listDomains, "domain", params)
    if list == nil
      return nil
    end
     
    list.each do |object|    
      return getDomain(object)
    end
  end
    
  def self.getDomain(object)   
    if object["name"] != nil  
      {
        :id             => object["id"],
        :name           => object["name"],   
        :networkdomain  => object["networkdomain"],   
        :parentid       => object["parentdomainid"],   
        :parent         => object["parentdomainname"],   
        :ensure         => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createDomain  
    Puppet.debug "Create Domain "+resource[:name]
            
    parent = self.class.getObject(resource[:parent])
      
    params = {         
      :name             => resource[:name],    
    }
        
    # Optional parameters     
    if resource[:networkdomain] != nil
      params[:networkdomain] = resource[:networkdomain]
    end
          
    if parent != nil
      params[:parentdomainid] = parent[:id]
    end
    
    Puppet.debug "createDomain PARAMS = "+params.inspect
    response = self.class.http_get('createDomain', params)
  end

  def deleteDomain
    Puppet.debug "Delete Domain "+resource[:name]
      
    id = lookupDomainId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteDomain PARAMS = "+params.inspect
    response = self.class.http_get('deleteDomain', params)    
    
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updateDomain
    Puppet.debug "Update Domain "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:networkdomain] != nil            
      id = lookupDomainId(resource[:name])
      params = { 
        :id               => id,# Puppet links name to ID, so changing name is not possible !      
        :networkdomain    => resource[:networkdomain],
      }
      Puppet.debug "updateDomain PARAMS = "+params.inspect
      response = self.class.http_get('updateDomain', params)    
    end
  end  
  
  def lookupDomainId(name) 
    domain = self.class.getObject(name)
    
    domain[:id]
  end
end