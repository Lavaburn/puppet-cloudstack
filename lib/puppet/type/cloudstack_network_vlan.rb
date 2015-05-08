# Custom Type: Cloudstack - Networking - VLAN IP Settings

Puppet::Type.newtype(:cloudstack_network_vlan) do
  @doc = "Cloudstack - Networking - VLAN IP Settings"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The VLAN name (Format: PHYNETWORK_VLAN_STARTIP)"    
  end
    
  newproperty(:vlan) do
    desc "The VLAN ID (-nil- for untagged)"
  end  
  
  newproperty(:zone) do  # ID
    desc "The zone that the VLAN belongs to"
  end  
  
#  newproperty(:pod) do  # ID
#    desc "The pod that the VLAN belongs to (UNTAGGED ONLY)"
#  end  
  
  newproperty(:account) do
    desc "The account that owns the VLAN"
  end  

  newproperty(:domain) do  # ID
    desc "The domain of the account that owns the VLAN"
  end  

  newproperty(:startip) do
    desc "The first IPv4 address"
  end    

  newproperty(:endip) do
    desc "The last IPv4 address"
  end  

  newproperty(:netmask) do
    desc "The netmask for the IPv4 addresses used"
  end  

  newproperty(:gateway) do
    desc "The gateway for the IPv4 addresses used"
  end
    
#  newproperty(:network) do    # ID
#    desc "The network to which the (guest) vlan is attached"
#  end  
  
  newproperty(:physicalnetwork) do   # ID
    desc "The physical network to which the (public) vlan is attached"
  end  

  # UNUSED:
    # startipv6 - endipv6 - ip6cidr - ip6gateway
    # forvirtualnetwork (true = Virtual, false = Direct)
    # projectid
end