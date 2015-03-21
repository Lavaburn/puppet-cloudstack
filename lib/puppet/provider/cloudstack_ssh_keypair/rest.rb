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
    list = get_objects(:listSSHKeyPairs, "sshkeypair")
    if list == nil
      return Array.new
    end
    
    list.collect do |object|    
      new(getKeypair(object))
    end 
  end
  
  def self.getObject(name) 
    params = { :name => name }
    get_objects(:listSSHKeyPairs, "keypair", params).collect do |object|    
      return getKeypair(object)
    end
  end
  
  def self.getKeypair(object)   
    
    
    #object["domainid"]
    #object["projectid"]
     
    {
      :name            => object["name"],      
      #:account         => object["account"],
      #:domain          => domain,
      #:project         => project,
      :ensure          => :present
    }
  end
  
  # TYPE SPECIFIC      
  private
  def create_keypair      
    if resource[:publickey] != nil
      Puppet.debug "Registering SSH Keypair #{resource[:name]}"
              
      params = { 
        :name      => resource[:name],
        :publickey => resource[:publickey],
        #:account   => resource[:account],
        #:domainid  => resource[:domain],# TODO CONVERT
        #:projectid => resource[:project],# TODO CONVERT    
      }
      response = self.class.http_get('registerSSHKeyPair', params)      
    else
      Puppet.debug "Creating SSH Keypair #{resource[:name]}"
  
      params = { 
           :name      => resource[:name],
           #:account   => resource[:account],
           #:domainid  => resource[:domain],# TODO CONVERT
           #:projectid => resource[:project],# TODO CONVERT
         }
      response = self.class.http_get('createSSHKeyPair', params)    
      
      keyfile = '/root/CLOUD_backdoor_'+resource[:name]+'.pem'
      File.open(keyfile, 'a') { |fd| 
        fd.puts response["keypair"]["privatekey"]
      }
      File.chmod(0600, keyfile)
      
      Puppet.notice "SSH Key saved to "+keyfile
    end
    
#      # Convert names to IDs
#      serviceofferingid = nil
#      
#      params = { "name" => resource[:serviceoffering] } 
#      list = self.class.get_objects(:listServiceOfferings, "serviceoffering", params)
#      if list != nil        
#        list.collect do |object|    
#          serviceofferingid = object["id"]
#        end
#      end
#      if serviceofferingid == nil
#        raise "Service Offering does not exist. Name = "+resource[:serviceoffering].inspect
#      end            
  end
  
  def delete_keypair
    Puppet.debug "Deleting SSH Keypair #{resource[:name]}"
    
    params = { :name => resource[:name] }
    response = self.class.http_get('deleteSSHKeyPair', params)
  end
end