require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_account).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Account"
  
  mk_resource_methods
  
  def flush        
    if @property_flush[:ensure] == :absent
      deleteAccount
      return
    end 
        
    if @property_flush[:ensure] != :absent
      return if createAccount
    end
        
    if @property_flush[:ensure] == :enabled
      enableAccount
      return
    end 
    
    if @property_flush[:ensure] == :locked
      lockAccount
      return
    end 
    
    if @property_flush[:ensure] == :disabled
      disableAccount
      return
    end 
    
    updateAccount
  end  

  def self.instances
    list = get_objects(:listAccounts, "account", { :listall => true })        
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getAccount(object)
      if map != nil
        #Puppet.debug "ACCOUNT FOUND: "+map.inspect
        result.push(new(map))
      end
    end 

    result 
  end
  
  def self.getObject(name) 
    params = { :name => name, :listall => true }
      
    list = get_objects(:listAccounts, "account", params)
    if list == nil
      return nil
    end
     
    list.each do |object|    
      return getAccount(object)
    end
  end
    
  def self.getAccount(object)   
    if object["name"] != nil 
      {
        :id             => object["id"],
        :name           => object["name"],   
        :accounttype    => accountTypes.fetch(object["accounttype"]),
        :domainid       => object["domainid"],             
        :domain         => object["domain"],   
        :networkdomain  => object["networkdomain"],   
        :state          => object["state"].downcase,
        :ensure         => :present
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
  def createAccount
    if @property_hash.empty?  
      Puppet.debug "Create Account "+resource[:name]
                
      params = {         
        :account        => resource[:name],   
        :accounttype    => self.class.accountTypes.key(resource["accounttype"]),
        :username       => resource[:username],  
        :firstname      => resource[:firstname],   
        :lastname       => resource[:lastname],   
        :email          => resource[:email],   
        :password       => resource[:password], 
      }
          
      # Optional parameters     
      if resource[:networkdomain] != nil
        params[:networkdomain] = resource[:networkdomain]
      end
    
      if domain != nil
        domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')   
        params[:domainid] = domainid
      end
      
      Puppet.debug "createAccount PARAMS = "+params.inspect
      response = self.class.http_get('createAccount', params)
      
      return true
    end
    
    false
  end

  def deleteAccount
    Puppet.debug "Delete Account "+resource[:name]
      
    id = lookupAccountId(resource[:name])
      
    params = { 
      :id => id,
    }
    Puppet.debug "deleteAccount PARAMS = "+params.inspect
    response = self.class.http_get('deleteAccount', params)    
    
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def updateAccount
    Puppet.debug "Update Account "+resource[:name]
            
    currentObject = self.class.getObject(@property_hash[:name])
      
    id = lookupAccountId(resource[:name])
      
    update_account = false
    if resource[:domain] != currentObject[:domain]
      update_account = true      
    end
    if resource[:networkdomain] != currentObject[:networkdomain]
      update_account = true      
    end
      
    if update_account
      params = {       
        :id               => id,# Puppet links name to ID, so changing name is not possible !      
        :newname          => resource[:name],
      }
      
      # Optional parameters     
      if resource[:networkdomain] != nil
        params[:networkdomain] = resource[:networkdomain]
      end
            
      if domain != nil
        domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')   
        params[:domainid] = domainid
      end
      
      Puppet.debug "updateAccount PARAMS = "+params.inspect
      response = self.class.http_get('updateAccount', params)  
    else 
      raise "Not every account field can be updated! Account can only update domain, networkdomain. To update the user enclosed in the account, create a new cloudstack_user with the same username."
    end
  end  
  
  def enableAccount
    Puppet.debug "Enable Account "+resource[:name]
      
    id = lookupAccountId(resource[:name])      
    params = {       
      :id => id,
    }
      
    Puppet.debug "enableAccount PARAMS = "+params.inspect
    response = self.class.http_get('enableAccount', params)        
  end
  
  def disableAccount
    Puppet.debug "Disable Account "+resource[:name]
    
    id = lookupAccountId(resource[:name])
    params = {       
      :id   => id,
      :lock => false,
    }
    
    Puppet.debug "disableAccount PARAMS = "+params.inspect
    response = self.class.http_get('disableAccount', params)    
    
    self.class.wait_for_async_call(response["jobid"])    
  end

  def lockAccount
    Puppet.debug "Lock Account "+resource[:name]
      
    id = lookupAccountId(resource[:name])
    params = {       
      :id   => id,
      :lock => true,
    }
    
    Puppet.debug "disableAccount PARAMS = "+params.inspect
    response = self.class.http_get('disableAccount', params)    
    
    self.class.wait_for_async_call(response["jobid"])    
  end
  
  def lookupAccountId(name) 
    account = self.class.getObject(name)
    
    account[:id]
  end
  
  def self.accountTypes
    {
      0 => 'user',
      1 => 'admin',
      2 => 'domain-admin',
    }
  end
end