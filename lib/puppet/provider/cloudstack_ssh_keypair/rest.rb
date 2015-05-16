require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_ssh_keypair).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack SSH Keypair"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      create_keypair
      return
    end
    
    if @property_flush[:ensure] == :absent
      delete_keypair
      return
    end 
    
    raise "Updates are not allowed for Cloudstack SSH Keypair"
  end  

  def self.instances
    result = Array.new
    
    lookup = {}
    list = getAllKeyPairs(lookup)
    
    if list != nil
      list.each do |object|    
        result.push(new(object))
      end       
    end    
    
    return result
  end
  
  def self.getObject(name) 
    lookup = { :name => name }
    list = getAllKeyPairs(lookup)

    if list != nil
      list.each do |object|    
        return object
      end      
    else
      raise "Could not find SSH Keypair #{name}"
    end
  end
  
  def self.getAllKeyPairs(lookup)    
    result = Array.new
    
    domains = get_objects(:listDomains, "domain")
    if domains != nil
      domains.each do |domain|
        accounts = get_objects(:listAccounts, "account", { :domainid => domain["id"] })
        if accounts != nil
          accounts.each do |account|            
            sshkeys = get_objects(:listSSHKeyPairs, "sshkeypair", { :listall => true, :account => account["name"], :domainid => domain["id"] })
            if sshkeys != nil
              sshkeys.each do |sshkey|
                object = {
                  :name    => sshkey["name"], 
                  :account => account["name"],
                  :domain  => domain["name"],
                  :ensure  => :present,
                }                
                result.push(object)
              end
            end         
          end
        end
      end
    end
    
    return result
  end
  
  # TYPE SPECIFIC      
  private
  def create_keypair         
    Puppet.debug "Creating SSH Keypair #{resource[:name]}"
            
    params = { 
      :name => resource[:name],
    }
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')   
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    
    # projectid
    
    if resource[:publickey] != nil
      Puppet.debug "Registering SSH Keypair"
              
      params[:publickey] = resource[:publickey]
      
      response = self.class.http_get('registerSSHKeyPair', params)      
    else
      Puppet.debug "Creating SSH Keypair"
  
      response = self.class.http_get('createSSHKeyPair', params)    
      
      keyfile = '/root/CLOUD_backdoor_'+resource[:name]+'.pem'
      File.open(keyfile, 'a') { |fd| 
        fd.puts response["keypair"]["privatekey"]
      }
      File.chmod(0600, keyfile)
      
      Puppet.notice "SSH Key saved to "+keyfile
    end  
  end
  
  def delete_keypair
    Puppet.debug "Deleting SSH Keypair #{resource[:name]}"
    
    params = { 
      :name => resource[:name] 
    }
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')   
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    
    # projectid    
    
    response = self.class.http_get('deleteSSHKeyPair', params)
  end
end