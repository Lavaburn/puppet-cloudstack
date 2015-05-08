# Custom Type: Cloudstack - Networking - Storage VLAN IP Settings

Puppet::Type.newtype(:cloudstack_network_storage_vlan) do
  @doc = "Cloudstack - Networking - Storage VLAN IP Settings"

  ensurable
 
  newparam(:name, :namevar => true) do
    desc "The VLAN name (Format: POD_STARTIP)"    
  end
    
  newproperty(:vlan) do
    desc "The VLAN ID"
  end  

  newproperty(:pod) do  # ID
    desc "The pod that the VLAN belongs to"
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
end