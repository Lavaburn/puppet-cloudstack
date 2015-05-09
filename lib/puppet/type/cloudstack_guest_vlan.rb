# Custom Type: Cloudstack - Networking - Guest VLAN (Dedication)

Puppet::Type.newtype(:cloudstack_guest_vlan) do
  @doc = "Cloudstack - Networking - Guest VLAN (Dedication)"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The VLAN Range to dedicate [FORMAT: start-end]"    
  end

  newproperty(:physicalnetwork) do # ID
    desc "The physical network on which the VLAN exists"
  end  
  
  newproperty(:account) do
    desc "The account that owns the VLAN"
  end  

  newproperty(:domain) do  # ID
    desc "The domain of the account that owns the VLAN"
  end  
  
  # UNUSED: project
end