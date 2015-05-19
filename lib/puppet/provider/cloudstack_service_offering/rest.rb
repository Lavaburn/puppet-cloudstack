require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_service_offering).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Service Offering"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createServiceOffering
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteServiceOffering
      return
    end 

    updateServiceOffering
  end  

  def self.instances    
    compute = get_objects(:listServiceOfferings, "serviceoffering", { :issystem => false })
    if compute == nil
      compute = Array.new
    end
    
    system = get_objects(:listServiceOfferings, "serviceoffering", { :issystem => true })
    if system == nil
      system = Array.new
    end
        
    list = compute + system    
    if list.count == 0
      return list
    end
    
    result = Array.new  
    list.each do |object|
      map = getServiceOffering(object)
      if map != nil
        #Puppet.debug "ServiceOffering FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    
    list = get_objects(:listServiceOfferings, "serviceoffering", params)
    if list == nil
      params = { :name => name, :issystem => true }
      list = get_objects(:listServiceOfferings, "serviceoffering", params)
    end
    
    if list == nil
      raise "Could not find Service Offering with name "+name
    end
    
    list.each do |object|    
      return getServiceOffering(object)
    end
  end
    
  def self.getServiceOffering(object)   
    if object["name"] != nil  
      if object["issystem"] == true or object["issystem"] == 'true'
        systemvm = object["systemvmtype"]
      else
        systemvm = false
      end
      
      tags = convertCSVtoArray(object["tags"])
      #hosttags = convertCSVtoArray(object["hosttags"])
                      
      {
        :id          => object["id"],
        :name        => object["name"],   
        :displaytext => object["displaytext"],   
        :cpunumber   => object["cpunumber"].to_s,
        :cpuspeed    => object["cpuspeed"].to_s,
        :memory      => object["memory"].to_s,
        :offerha     => object["offerha"],   
        :storagetype => object["storagetype"],     
        :tags        => tags,   
        #:hosttags    => hosttags,   
        :systemvm    => systemvm,   
        :ensure      => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createServiceOffering
    Puppet.debug "Create ServiceOffering "+resource[:name]
      
    params = {         
      :name         => resource[:name],   
      :displaytext  => resource[:displaytext],   
      :cpunumber    => resource[:cpunumber],   
      :cpuspeed     => resource[:cpuspeed],   
      :memory       => resource[:memory],   
      :offerha      => resource[:offerha],   
      :storagetype  => resource[:storagetype],
      :tags         => resource[:tags].join(","),  
      #:hosttags     => resource[:hosttags].join(","),  
    }
    
    # Variable parameters     
    if resource[:systemvm] == nil or resource[:systemvm] == false or resource[:systemvm] == 'false'
      params[:issystem] = false
    else
      params[:issystem] = true
      params[:systemvmtype] = resource[:systemvm].downcase
    end
   
    Puppet.debug "createServiceOffering PARAMS = "+params.inspect
    response = self.class.http_get('createServiceOffering', params)
  end

  def deleteServiceOffering
    Puppet.debug "Delete ServiceOffering "+resource[:name]
      
    id = lookupServiceOfferingId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteServiceOffering PARAMS = "+params.inspect
    response = self.class.http_get('deleteServiceOffering', params)           
  end
  
  def updateServiceOffering
    Puppet.debug "Update ServiceOffering "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:displaytext] != currentObject[:displaytext]
      id = lookupServiceOfferingId(resource[:name])
      params = { 
        :id          => id,# Puppet links name to ID, so changing name is not possible !
        :displaytext => resource[:displaytext],   
      }
                  
      Puppet.debug "updateServiceOffering PARAMS = "+params.inspect
      response = self.class.http_get('updateServiceOffering', params)  
    else
      raise "Settings for ServiceOffering can not be updated! Only displaytext can be changed."
    end  
  end  
  
  def lookupServiceOfferingId(name) 
    serviceOffering = self.class.getObject(name)
    
    serviceOffering[:id]
  end
end