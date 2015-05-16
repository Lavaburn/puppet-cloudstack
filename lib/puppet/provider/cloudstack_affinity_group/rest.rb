require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_affinity_group).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Affinity Group"
  
  mk_resource_methods
 
  def flush 
    if @property_flush[:ensure] == :present
      createAffinityGroup
      return
    end
              
    if @property_flush[:ensure] == :absent
      deleteAffinityGroup
      return
    end
    
    raise "Affinity Group update is not supported."
  end  

  def self.instances   
    list = get_objects(:listAffinityGroups, "affinitygroup", { :listall => true })    
    if list == nil
      return Array.new
    end
    
    result = Array.new  
    list.each do |object|
      map = {
        :name        => object["name"],
        :description => object["description"],
        :type        => object["type"],
        :account     => object["account"],
        :domain      => object["domain"],
        :ensure      => :present
      }
      if map != nil
        #Puppet.debug "Affinity Group FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
   
  # TYPE SPECIFIC      
  private
  def createAffinityGroup  
    Puppet.debug "Creating Affinity Group "+resource["name"]
            
    params = { 
      :name        => resource[:name],
      :description => resource[:description],
      :type        => resource[:type],
    }
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')   
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    
    response = self.class.http_get('createAffinityGroup', params)
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def deleteAffinityGroup    
    Puppet.debug "Deleting Affinity Group "+resource["name"]
      
    params = { 
      :name        => resource[:name],
    }
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')   
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    
    response = self.class.http_get('deleteAffinityGroup', params)
    self.class.wait_for_async_call(response["jobid"])    
  end
end