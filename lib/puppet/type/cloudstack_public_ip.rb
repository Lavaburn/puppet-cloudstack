# Custom Type: Cloudstack - Public IP

Puppet::Type.newtype(:cloudstack_public_ip) do
  @doc = "Cloudstack Public IP"

  ensurable
        
  newparam(:name, :namevar => true) do    # ID
    desc "The associated network (name)"
  end
  
  newproperty(:count) do
    desc "The amount of Public IPs you want allocated to the network"
  end
  
# account / domainid / projectid
# zoneid
end