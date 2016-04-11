require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_iso).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack ISO"
  
  mk_resource_methods
  
  def flush          
    if @property_flush[:ensure] == :present
      createISO
      return
    end
          
    if @property_flush[:ensure] == :absent
      deleteISO
      return
    end 
    
    updateISO
  end  

  def self.instances
    result = Array.new      
    
    list = get_objects(:listIsos, "iso", { :listall => true, :isofilter => 'all' })             
    if list != nil  
      list.each do |object|
        map = getISO(object)
        if map != nil
          #Puppet.debug "ISO FOUND: "+map.inspect
          result.push(new(map))
        end
      end 
    end   

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name, :listall => true, :isofilter => 'all' }      
    list = get_objects(:listIsos, "iso", params)
    if list != nil
      list.each do |object|    
        return getISO(object)
      end
    end
    
    return nil    
  end
    
  def self.getISO(object)   
    if object["name"] != nil 
      {
        :id             => object["id"],
        :name           => object["name"],   
        :displaytext    => object["displaytext"],   
        :zoneid         => object["zoneid"],             
        :zone           => object["zonename"],     
        :bootable       => object["bootable"],           
        :extractable    => object["isextractable"],           
        :featured       => object["isfeatured"],           
        :public         => object["ispublic"], 
        :ostypeid       => object["ostypeid"],            
        :ostype         => object["ostypename"],           
        :account        => object["account"],           
        :domainid       => object["domainid"],           
        :domain         => object["domain"],          
#        :projectid      => object["projectid"],    
#        :project        => object["project"],           
        :ensure         => :present
      }
    end
  end
  
  # TYPE SPECIFIC    
  private
  def createISO
    Puppet.debug "Create ISO "+resource[:name]
      
    zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
    ostypeid = self.class.genericLookup(:listOsTypes, 'ostype', 'description', resource[:ostype], {}, 'id')
#    projectid = self.class.genericLookup(:listProjects, 'project', 'name', resource[:project], {}, 'id')
    
    params = {          
        :url             => resource[:url], 
        :name            => resource[:name], 
        :displaytext     => resource[:displaytext], 
        :zoneid          => zoneid, 
        :bootable        => resource[:bootable], 
        :isextractable   => resource[:extractable], 
        :isfeatured      => resource[:featured], 
        :ispublic        => resource[:public], 
        :ostypeid        => ostypeid, 
#        :projectid       => projectid,      
    }
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    

    Puppet.debug "registerIso PARAMS = "+params.inspect
    response = self.class.http_get('registerIso', params)
  end

  def deleteISO
    Puppet.debug "Delete ISO "+resource[:name]
      
    id = lookupId
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteIso PARAMS = "+params.inspect
    response = self.class.http_get('deleteIso', params)        
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updateISO
    Puppet.debug "Update ISO "+resource[:name]
            
    currentObject = self.class.getObject(@property_hash[:name])
      
    id = lookupId
     
    update_account = false
    if resource[:bootable] != currentObject[:bootable]
      update_account = true      
    end
    if resource[:displaytext] != currentObject[:displaytext]
      update_account = true      
    end
    if resource[:ostype] != currentObject[:ostype]      
      update_account = true      
    end
    
    if update_account
      ostypeid = self.class.genericLookup(:listOsTypes, 'ostype', 'description', resource[:ostype], {}, 'id')
      
      params = {       
        :id              => id,# Puppet links name to ID, so changing name is not possible !   
        :displaytext     => resource[:displaytext], 
        :bootable        => resource[:bootable], 
        :ostypeid        => ostypeid, 
      }
      
      Puppet.debug "updateIso PARAMS = "+params.inspect
      response = self.class.http_get('updateIso', params)  
    else 
      raise "Not every ISO field can be updated! ISO can only update: bootable, displaytext, ostype"
    end
  end  
    
  def lookupId
    iso = self.class.getObject(resource[:name])    
    iso[:id]
  end  
end