# Custom Type: Cloudstack - VirtualRouter Element

Puppet::Type.newtype(:cloudstack_virtual_router_element) do
  @doc = "Cloudstack VirtualRouter Element"

  ensurable do
    defaultto :present
 
    newvalue(:present) do
      provider.setState(:present)      
    end
     
    newvalue(:enabled) do
      provider.setState(:enabled)
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
  
  newproperty(:providertype) do
    desc "The service provider type (VirtualRouter/VpcVirtualRouter)"
  end  
      
  # LIST ONLY: 
    # account/domain/project
end