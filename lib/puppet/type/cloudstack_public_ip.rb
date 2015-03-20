# Custom Type: Cloudstack - Public IP

Puppet::Type.newtype(:cloudstack_public_ip) do
  @doc = "Cloudstack Public IP"

  ensurable
        
  newparam(:name, :namevar => true) do
    desc "The associated network (name)"
  end
  
  newproperty(:count) do
    desc "The amount of Public IPs you want allocated to the network"
  end
  
  newparam(:networkid) do
    desc "The associated network id"
  end
  
  newparam(:iplist) do
    desc "The public IP list"
  end
  
#  newparam(:zoneid) do
#    desc "The zone id"
#  end
end