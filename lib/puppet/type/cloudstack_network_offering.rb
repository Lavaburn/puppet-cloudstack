# Custom Type: Cloudstack - Network Offering

Puppet::Type.newtype(:cloudstack_network_offering) do
  @doc = "Cloudstack Network Offering"

  ensurable do
    defaultto :present
 
    newvalue(:present) do
      provider.setState(:present)      
    end
     
    newvalue(:enabled) do
      provider.setState(:enabled)
    end
     
#    newvalue(:inactive) do
#      provider.setState(:inactive)
#    end
   
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
#          when :inactive
#            return false if is == :absent                          
#            return (provider.getState == "inactive")
          when :disabled
            return false if is == :absent                          
            return (provider.getState == "disabled")       
        end
      }            
      false             
    end
  end
        
  newparam(:name, :namevar => true) do
    desc "The network offering name"    
  end
  
  newproperty(:displaytext) do
    desc "The network offering description"
  end  
          
  newproperty(:guestiptype) do
    desc "The guest IP type (shared/isolated)"
  end  
          
#  newproperty(:traffictype) do
#    desc "The traffic type (guest)"
#  end  
          
  newproperty(:ispersistent) do
    desc "(boolean) Whether the network will remain up if no VMs in the network are running."
    defaultto false
  end  

  newproperty(:conservemode) do
    desc "(boolean) In conserve mode, more than 1 service can be allocated to a public IP."
    defaultto true
  end    

  newproperty(:availability) do
    desc "(Optional/Required) 'Required' enables redundancy for System Routers [needs: Isolated - SourceNAT] [only 1 per system ?]"
  end

  newproperty(:specifyvlan) do
    desc "(boolean) Enable VLAN support [needs: Isolated]"
  end  

  newproperty(:specifyipranges) do
    desc "(boolean) Whether user can specify Guest IP ranges [needs: Isolated - NOT SourceNAT]"
  end    
  
  newproperty(:egressdefaultpolicy) do
    desc "(boolean) The default egress firewall policy (true = allow, false = deny)"
  end  
            
  newproperty(:serviceoffering) do
    desc "The Service Offering for the System VM"
    defaultto "System Offering for Software"
  end 
  
  newparam(:service, :array_matching => :all) do    # TODO Change back to property when comparison is good...
    desc "The supported services. Array of Hashes! name, provider. Provider = array of hash! name."
    # eg. "service" => [ {"name"=>"Dns", "provider"=>[{"name"=>"VirtualRouter"}]}, ]
  end 
            
  newproperty(:tags, :array_matching => :all) do
    desc "The network tags (???)"
  end  
         
  # Unused:      
  #   networkrate
  #   maxconnections
  #   keepaliveenabled (enables keepalive for Load Balancers (HAProxy)
  
  # List Only (can't set or change):
  #   state  =>  Disabled/Enabled/Inactive
    
end