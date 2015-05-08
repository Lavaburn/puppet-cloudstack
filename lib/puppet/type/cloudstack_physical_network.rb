# Custom Type: Cloudstack - Physical Network

Puppet::Type.newtype(:cloudstack_physical_network) do
  @doc = "Cloudstack Physical Network"

  ensurable   # Enable/Disable ??
      
  newparam(:name, :namevar => true) do
    desc "The physical network name"    
  end
    
  newproperty(:zone) do   # ID
    desc "The zone that this physical network belongs to"
  end  
  
  newproperty(:domain) do  # ID
    desc "The domain that this physical network belongs to"
  end  
  
  newproperty(:isolationmethods) do
    desc "The isolation method (VLAN/GRE/L3)"
  end  
  
  newproperty(:vlan) do
    desc "The VLAN tag"
  end  
  
  newproperty(:tags, :array_matching => :all) do
    desc "The network tags"
  end  
  
  # UNUSED:
    # networkspeed (1G)
    # broadcastdomainrange [Zone => Advanced / Pod => Basic]
end