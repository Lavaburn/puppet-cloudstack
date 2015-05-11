# Custom Type: Cloudstack - Primary Storage

Puppet::Type.newtype(:cloudstack_primary_storage) do
  @doc = "Cloudstack Primary Storage"

  ensurable do
    defaultto :present
    
    newvalue(:present) do
      provider.setState(:present)      
    end

    newvalue(:absent) do
      provider.setState(:absent)      
    end
    
    newvalue(:maintenance) do
      provider.setState(:maintenance)
    end
  
    newvalue(:up) do
      provider.setState(:up)
    end
    
    def insync?(is)
      @should.each { |should| 
        case should
          when :present
            return true unless [:absent].include?(is)
          when :absent
            return true if is == :absent
          when :maintenance
            return false if is == :absent
                  
            return (provider.getState == "prepareformaintenance" or provider.getState == "maintenance")      
          when :up
            return false if is == :absent
                  
            return (provider.getState == "up")  
        end
      }            
      false   
         
    end
  end
      
  newparam(:name, :namevar => true) do
    desc "The storage unit name"    
  end
  
  newproperty(:scope) do
    desc "The scope of this storage unit (zone/cluster)"
  end  
  
  newproperty(:zone) do
    desc "The zone that this storage unit belong to"
  end  
  
  newproperty(:pod) do
    desc "The pod that this storage unit belong to [Scope=Cluster]"
  end  
  
  newproperty(:cluster) do
    desc "The cluster that this storage unit belong to [Scope=Cluster]"
  end  
  
  newproperty(:hypervisor) do
    desc "The hypervisor type that this storage unit can be used by (KVM/VMWare/Hyperv) [Scope=Zone]"
  end  
  
  newproperty(:url) do
    desc "The URL to reach/setup the storage unit (nfs://host/path ; presetup://localhost/label ; iscsi://IQN?)"
  end  
  
  newproperty(:tags, :array_matching => :all) do
    desc "The storage tags"
  end  
  
  # UNUSED:
  # capacitybytes - capacityiops
  # details - managed
end