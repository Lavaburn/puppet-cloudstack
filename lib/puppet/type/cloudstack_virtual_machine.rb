# Custom Type: Cloudstack - Virtual Machine

Puppet::Type.newtype(:cloudstack_virtual_machine) do
  @doc = "Cloudstack Virtual Machine"

  ensurable do
    defaultto :present
    
    newvalue(:present) do
      provider.setState(:present)      
    end

    newvalue(:absent) do
      provider.setState(:absent)      
    end

    newvalue(:running) do
      provider.setState(:running)
    end

    newvalue(:stopped) do
      provider.setState(:stopped)
    end
    
    def insync?(is)
      @should.each { |should| 
        case should
          when :present
            return true unless [:absent].include?(is)
          when :absent
            return true if is == :absent
          when :running
            return false if is == :absent
                        
            return (provider.getState == "running")
          when :stopped
            return false if is == :absent
                  
            return (provider.getState == "stopped")      
        end
      }            
      false   
         
    end
  end
  
  newparam(:id) do
    desc "The ID (read only)"    
  end
    
  newparam(:name, :namevar => true) do
    desc "The name"    
  end
  
  newproperty(:account) do
    desc "The account (name)"
  end
  
  newproperty(:domain) do
    desc "The account domain (name)"
  end
  
  newproperty(:zone) do
    desc "The zone (name)"
  end  
  
  newproperty(:template) do
    desc "The template (name)"
  end
  
  newproperty(:serviceoffering) do
    desc "The service offering (name)"
  end
          
  newproperty(:default_network) do
    desc "The default network (name)"
  end
    
  newproperty(:userdata) do
    desc "The user data (BASE64 encoded)"
  end
  
  newproperty(:keypair) do
    desc "The SSH Keypair"
  end

  newproperty(:affinitygroups, :array_matching => :all) do
    desc "The Affinity Groups (Array of names)"
  end

  newproperty(:extra_networks, :array_matching => :all) do
    desc "Attach extra NICs (Array of names)"
    defaultto [] 
    
    def insync?(is)
      if is.empty? and should.empty?
        return true
      end

      if !is.empty? and !should.empty?
        return is == should
      end
      
      return false
    end
  end
  
  # UNUSED ?   
    # displayname, group, haenable, hostname, project
end