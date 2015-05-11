require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_disk_offering).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Disk Offering"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createDiskOffering
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteDiskOffering
      return
    end 

    updateDiskOffering
  end  

  def self.instances    
    list = get_objects(:listDiskOfferings, "diskoffering")
    if list == nil
      return Array.new
    end
    
    result = Array.new  
    list.each do |object|
      map = getDiskOffering(object)
      if map != nil
        #Puppet.debug "DiskOffering FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name }    
    list = get_objects(:listDiskOfferings, "diskoffering", params)    
    if list == nil
      raise "Could not find Disk Offering with name "+name
    end
    
    list.each do |object|    
      return getDiskOffering(object)
    end
  end
    
  def self.getDiskOffering(object)   
    if object["name"] != nil        
      tags = convertCSVtoArray(object["tags"])
              
      {
        :id          => object["id"],
        :name        => object["name"],   
        :displaytext => object["displaytext"],   
        :storagetype => object["storagetype"],  
        :disksize     => object["disksize"].to_s,   
        :tags        => tags,   
        :ensure      => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createDiskOffering
    Puppet.debug "Create DiskOffering "+resource[:name]
      
    params = {         
      :name         => resource[:name],   
      :displaytext  => resource[:displaytext], 
      :storagetype  => resource[:storagetype],
      :disksize     => resource[:disksize],   
      :tags         => resource[:tags].join(","),  
    }
   
    Puppet.debug "createDiskOffering PARAMS = "+params.inspect
    response = self.class.http_get('createDiskOffering', params)
  end

  def deleteDiskOffering
    Puppet.debug "Delete DiskOffering "+resource[:name]
      
    id = lookupDiskOfferingId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteDiskOffering PARAMS = "+params.inspect
    response = self.class.http_get('deleteDiskOffering', params)           
  end
  
  def updateDiskOffering
    Puppet.debug "Update DiskOffering "+resource[:name]
      
    currentObject = self.class.getObject(@property_hash[:name])
      
    if resource[:displaytext] != currentObject[:displaytext]
      id = lookupDiskOfferingId(resource[:name])
      params = { 
        :id          => id,# Puppet links name to ID, so changing name is not possible !
        :displaytext => resource[:displaytext],   
      }
                  
      Puppet.debug "updateDiskOffering PARAMS = "+params.inspect
      response = self.class.http_get('updateDiskOffering', params)  
    else
      raise "Settings for DiskOffering can not be updated! Only displaytext can be changed."
    end  
  end  
  
  def lookupDiskOfferingId(name) 
    diskOffering = self.class.getObject(name)
    
    diskOffering[:id]
  end
end