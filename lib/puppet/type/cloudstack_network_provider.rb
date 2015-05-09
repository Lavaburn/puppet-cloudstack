# Custom Type: Cloudstack - Network Service Provider

Puppet::Type.newtype(:cloudstack_network_provider) do
  @doc = "Cloudstack Network"

  ensurable do
    defaultto :present
 
    newvalue(:present) do
      provider.setState(:present)      
    end
     
    newvalue(:enabled) do
      provider.setState(:enabled)
    end
     
    newvalue(:shutdown) do
      provider.setState(:shutdown)
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
          when :shutdown
            return false if is == :absent                          
            return (provider.getState == "shutdown")
          when :disabled
            return false if is == :absent                          
            return (provider.getState == "disabled")       
        end
      }            
      false             
    end
  end
      
  newparam(:name, :namevar => true) do
    desc "The provider name [Format: Network_Provider]"    
  end

  newproperty(:physicalnetwork) do  # ID
    desc "The physical network that the provider is linked to"
  end  
  
  newproperty(:service_provider) do
    desc "The service provider name"
  end  
      
  # UNUSED:
    # [C/R  ] destinationphysicalnetworkid
    # [C/R/U] servicelist
    # [  R  ] canenableindividualservice
end