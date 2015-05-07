# Custom Type: Cloudstack - Account

Puppet::Type.newtype(:cloudstack_account) do
  @doc = "Cloudstack Account"

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.setState(:present)      
    end
    
    newvalue(:enabled) do
      provider.setState(:enabled)
    end
    
    newvalue(:locked) do
      provider.setState(:locked)
    end
  
    newvalue(:disabled) do
      provider.setState(:disabled)
    end
    
    newvalue(:absent) do
      provider.setState(:absent)      
    end
        
    def insync?(is)
      @should.each { |should| 
        case should
          when :present
            return true unless [:absent].include?(is)
          when :absent
            return true if is == :absent
          when :enabled
            return false if is == :absent                          
            return (provider.getState == "enabled")
          when :locked
            return false if is == :absent                          
            return (provider.getState == "locked")
          when :disabled
            return false if is == :absent                          
            return (provider.getState == "disabled")       
        end
      }            
      false             
    end
  end
  
  newparam(:name, :namevar => true) do
    desc "The account name"
  end
  
  newproperty(:accounttype) do
    desc "The account type (user, admin, domain-admin)"   
    defaultto 'user'
    # TODO VALIDATE    
  end  
  
  newproperty(:domain) do
    desc "The domain to assign this account under"
  end  
  
  newproperty(:networkdomain) do
    desc "The domainname (DNS) (eg. test.org) to use when creating VMs under this account"
  end
  
  newparam(:username) do
    desc "The first user assigned to the account"
  end  
  
  newparam(:firstname) do
    desc "The first name"
  end  
  
  newparam(:lastname) do
    desc "The last name"
  end  
  
  newparam(:email) do
    desc "The e-mail address"
  end 
  
  newparam(:password) do
    desc "The password" 
  end  
end