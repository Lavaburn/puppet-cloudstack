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
  
  newproperty(:id) do
    desc "The ID (read only)"    
  end
    
  newparam(:name, :namevar => true) do
    desc "The name"    
  end
  
  newproperty(:account) do
    desc "The account (name)"
  end
  
#  newproperty(:domainid) do
#    desc "The account domain ID"
#  end
  
  newproperty(:domain) do
    desc "The account domain (name)"
  end
      
#  newproperty(:zoneid) do
#    desc "The zone ID"
#  end
  
  newproperty(:zone) do
    desc "The zone (name)"
  end  
  
#  newproperty(:templateid) do
#    desc "The template ID"
#  end

  newproperty(:template) do
    desc "The template (name)"
  end
  
#  newproperty(:serviceofferingid) do
#     desc "The service offering ID"
#   end
 
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

    
  # TODO   
  # projectid   
    
  # OUTPUT ONLY ???
  #  "id"=>"84831abb-8d6d-4b52-96c5-b1c24a55cce2", 
  #  "displayname"=>"VM-84831abb-8d6d-4b52-96c5-b1c24a55cce2",   
  #  "created"=>"2015-03-16T20:09:49+0300", 
  #  "haenable"=>true, 
  #  "templatedisplaytext"=>"Ubuntu 14.04.2 LTS (Trusty Tahr) (XenServer)", 
  #  "passwordenabled"=>true, 
  #  "cpunumber"=>1,
  #  "cpuspeed"=>2400, 
  #  "memory"=>2048, 
  #  "cpuused"=>"1.34%", 
  #  "networkkbsread"=>22431114, 
  #  "networkkbswrite"=>2053, 
  #  "diskkbsread"=>0, 
  #  "diskkbswrite"=>0, 
  #  "diskioread"=>0, 
  #  "diskiowrite"=>0, 
  #  "guestosid"=>"c1ba6d13-c299-11e4-98e1-82ad7fa9d21c", 
  #  "rootdeviceid"=>0, 
  #  "rootdevicetype"=>"ROOT", 
  #  "securitygroup"=>[], 
  #  "nic"=>[{
  #      "id"=>"b4255b0a-6a9c-4573-bd1a-80083cabf974", 
  #      "networkid"=>"0eb1d628-284d-4229-9362-ef9d25f78a43", 
  #      "networkname"=>"RCS Public Services", 
  #      "netmask"=>"255.255.255.0", 
  #      "gateway"=>"172.20.110.1", 
  #      "ipaddress"=>"172.20.110.101", 
  #      "isolationuri"=>"vlan://3151", 
  #      "broadcasturi"=>"vlan://3151", 
  #      "traffictype"=>"Guest", 
  #      "type"=>"Isolated",
  #      "isdefault"=>true, 
  #      "macaddress"=>"02:00:0a:b6:00:2b"}
  #  ], 
  #  "hypervisor"=>"XenServer",   
  #  "publicipid"=>"a428d0dd-8499-4409-885e-d3d995cb0137", 
  #  "publicip"=>"105.235.209.13", 
  #  "tags"=>[],   
  #  "details"=>{"hypervisortoolsversion"=>"xenserver56"}, 
  #  "affinitygroup"=>[], 
  #  "isdynamicallyscalable"=>false, 
  #  "ostypeid"=>103}
  
   

  # This is not support by Puppet (<= 3.7)...
#  autorequire(:class) do
#    'cs_mgmt'
#  end
end