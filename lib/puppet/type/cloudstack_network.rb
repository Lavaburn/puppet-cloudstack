# Custom Type: Cloudstack - Network

Puppet::Type.newtype(:cloudstack_network) do
  @doc = "Cloudstack Network"

  ensurable   # TODO Enable/Disable ??
      
  newparam(:name, :namevar => true) do
    desc "The network name"    
  end
    
  newproperty(:displaytext) do
    desc "The network description"
  end  
  
  newproperty(:networkoffering) do  # ID
    desc "The network offering used by this network"
  end  
  
  newproperty(:zone) do  # ID
    desc "The zone that this network belongs to"
  end  
    
  newproperty(:physicalnetwork) do  # ID
    desc "The physical network that the network is linked to"
  end  
  
  newproperty(:vlan) do
    desc "The  VLAN used by this network"
  end  
    
  newproperty(:startip) do
    desc "The startip"
  end  
  
  newproperty(:endip) do
    desc "The endip"
  end  
  
  newproperty(:netmask) do
    desc "The netmask"
  end  
  
  newproperty(:gateway) do
    desc "The gateway"
  end    

  newproperty(:account) do
    desc "The account that owns the network"
  end  
  
  newproperty(:domain) do # ID
    desc "The domain of the account that owns the network"
  end  

  newproperty(:networkdomain) do
    desc "The domainname (DNS) (eg. test.org) to use when creating VMs on this network"
  end  
    
  # UNUSED:
    # startipv6 - endipv6 - ip6cidr - ip6gateway
    # acltype - aclid
    # projectid
    # displaynetwork (show to user)
    # isolatedpvlan
    # subdomainaccess
    # vpcid
end