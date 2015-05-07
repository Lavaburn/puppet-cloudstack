require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_user).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack User"
  
  mk_resource_methods
  
  def flush        
    if @property_flush[:ensure] == :absent
      deleteUser
      return
    end 
        
    if @property_flush[:ensure] != :absent
      return if createUser
    end
        
    if @property_flush[:ensure] == :enabled
      enableUser
      return
    end 
    
    if @property_flush[:ensure] == :locked
      lockUser
      return
    end 
    
    if @property_flush[:ensure] == :disabled
      disableUser
      return
    end 
    
    updateUser
  end  

  def self.instances
    list = get_objects(:listUsers, "user", { :listall => true })        
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getUser(object)
      if map != nil
        Puppet.debug "USER FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :username => name }
      
    list = get_objects(:listUsers, "user", params)
    if list == nil
      return nil
    end
     
    list.each do |object|    
      return getUser(object)
    end
  end
    
  def self.getUser(object)   
    if object["username"] != nil 
      {
        :id         => object["id"],
        :name       => object["username"], 
        :account    => object["account"],  
        #:accountid => object["accountid"],            
        :domain    => object["domain"],  
        #:domainid => object["domainid"],  
        :firstname  => object["firstname"],   
        :lastname   => object["lastname"],   
        :email      => object["email"],   
        :state      => object["state"].downcase,
        :ensure     => :present
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
  def createUser
    if @property_hash.empty?  
      Puppet.debug "Create User "+resource[:name]
        
      domain = getDomain(resource[:domain])
        
      params = {         
        :username       => resource[:name],  
        :account        => resource[:account],   
        :domainid       => domain["id"],
        :firstname      => resource[:firstname],   
        :lastname       => resource[:lastname],   
        :email          => resource[:email],   
        :password       => resource[:password], 
      }
         
      Puppet.debug "createUser PARAMS = "+params.inspect
      response = self.class.http_get('createUser', params)
      
      return true
    end
    
    false
  end

  def deleteUser
    Puppet.debug "Delete User "+resource[:name]
   
    id = lookupUserId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteUser PARAMS = "+params.inspect
    response = self.class.http_get('deleteUser', params)    
  end
  
  def updateUser
    Puppet.debug "Update User "+resource[:name]
            
    currentObject = self.class.getObject(@property_hash[:name])
      
    id = lookupUserId(resource[:name])         
      
    if resource[:account] != currentObject[:account]
      raise "User can not be re-allocated to another account after creation! (User = "+resource[:name]+")"
    end
    
    if resource[:domain] != currentObject[:domain]
      raise "User can not be re-allocated to another account (hence domain) after creation! (User = "+resource[:name]+")"
    end
        
    params = {       
      :id         => id,# Puppet links username to ID, so changing username is not possible !      
      :firstname  => resource[:firstname],         
      :lastname   => resource[:lastname],         
      :email      => resource[:email],    
    }
      
    Puppet.debug "updateUser PARAMS = "+params.inspect
    response = self.class.http_get('updateUser', params)  
  end  
  
  def enableUser
    Puppet.debug "Enable User "+resource[:name]
      
    id = lookupUserId(resource[:name])      
    params = {       
      :id => id,
    }
      
    Puppet.debug "enableUser PARAMS = "+params.inspect
    response = self.class.http_get('enableUser', params)        
  end
  
  def disableUser
    Puppet.debug "Disable User "+resource[:name]
    
    id = lookupUserId(resource[:name])
    params = {       
      :id   => id,
    }
    
    Puppet.debug "disableUser PARAMS = "+params.inspect
    response = self.class.http_get('disableUser', params)    
    
    self.class.wait_for_async_call(response["jobid"])    
  end

  def lockUser
    Puppet.debug "Lock User "+resource[:name]
      
    id = lookupUserId(resource[:name])
    params = {       
      :id   => id,
    }
    
    Puppet.debug "lockUser PARAMS = "+params.inspect
    response = self.class.http_get('lockUser', params)    
  end
  
  def lookupUserId(name) 
    user = self.class.getObject(name)
    
    user[:id]
  end
  
  def getDomain(name)
    params = { :name => name }
          
    list = self.class.get_objects(:listDomains, "domain", params)
    if list == nil
      return nil
    end
         
    list.each do |object|    
      return object
    end
  end
end