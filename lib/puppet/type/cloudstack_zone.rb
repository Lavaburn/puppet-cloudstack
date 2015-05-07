# Custom Type: Cloudstack - Zone

Puppet::Type.newtype(:cloudstack_zone) do
  @doc = "Cloudstack Zone"

  ensurable
      
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
  
  newproperty(:domain) do
    desc "The zone domain name"
  end  
  
  newproperty(:guestcidraddress) do
    desc "The CIDR for guest traffic in the zone"
  end    
  
#  allocationstate
#  ip6dns1
#  ip6dns2
#  localstorageenabled
#  securitygroupenabled
end