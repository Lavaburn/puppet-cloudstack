# Custom Type: Cloudstack - Host

Puppet::Type.newtype(:cloudstack_host) do
  @doc = "Cloudstack Host"
    
  ensurable do
    defaultto :present
    
    newvalue(:present) do
      provider.setState(:present)      
    end

    newvalue(:absent) do
      provider.setState(:absent)      
    end
  
    newvalue(:enabled) do
      provider.setState(:enabled)
    end
    
    newvalue(:disabled) do
      provider.setState(:disabled)
    end
    
    newvalue(:maintenance) do
      provider.setState(:maintenance)
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
          when :disabled
            return false if is == :absent
                        
            return (provider.getState == "disabled")
          when :maintenance
            return false if is == :absent
                  
            return (provider.getState == "prepareformaintenance" or provider.getState == "maintenance")      
        end
      }            
      false   
         
    end
  end
  
  newparam(:name, :namevar => true) do
    desc "The hostname"    
  end
  
  newparam(:ipaddress) do
    desc "The host ip address"
  end 
  
  newparam(:username) do
    desc "The host username"
  end 
  
  newparam(:password) do
    desc "The host password"
  end 

  newproperty(:hypervisor) do
    desc "The host hypervisor (XenServer,KVM,VMware,Hyperv,BareMetal,Simulator)"
  end 

  newproperty(:cluster) do
    desc "The cluster that this host belongs to"
  end 

  newproperty(:pod) do
    desc "The pod that this host belongs to"
  end 

  newproperty(:zone) do
    desc "The zone that this host belongs to"
  end 
  
  newproperty(:tags, :array_matching => :all) do    # UPDATE possible
    desc "The host tags"
  end 
end