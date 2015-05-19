# Custom Type: Cloudstack - Zone

Puppet::Type.newtype(:cloudstack_zone) do
  @doc = "Cloudstack Zone"

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
    desc "The zone name"    
  end
  
  newproperty(:networktype) do
    desc "The zone type (Basic/Advanced)"
  end  
  
  newproperty(:dns1) do
    desc "The zone External DNS Server"
  end  
  
  newproperty(:dns2) do
    desc "The zone External DNS Server2"
  end  
  
  newproperty(:internaldns1) do
    desc "The zone Internal DNS Server"
  end  
  
  newproperty(:internaldns2) do
    desc "The zone Internal DNS Server2"
  end  
  
  newproperty(:networkdomain) do
    desc "The domainname (DNS) (eg. test.org) to use when creating VMs under this zone"
  end  
  
  newproperty(:guestcidraddress) do
    desc "The CIDR for guest traffic in the zone"
  end    
  
#  ip6dns1
#  ip6dns2
#  localstorageenabled
#  securitygroupenabled
end