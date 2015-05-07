# Custom Type: Cloudstack - User

Puppet::Type.newtype(:cloudstack_user) do
  @doc = "Cloudstack User"

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
    desc "The user name"
  end
  
  newproperty(:account) do
    desc "The account under which to create this user"
  end  
  
  newproperty(:domain) do
    desc "The domain to which the account belongs"
  end  
  
  newproperty(:firstname) do
    desc "The first name"
  end  
  
  newproperty(:lastname) do
    desc "The last name"
  end  
  
  newproperty(:email) do
    desc "The e-mail address"
  end 
  
  newparam(:password) do
    desc "The password (clear-text) [CREATE ONLY]"
  end  
end