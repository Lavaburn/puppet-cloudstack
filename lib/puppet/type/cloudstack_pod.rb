# Custom Type: Cloudstack - Pod

Puppet::Type.newtype(:cloudstack_pod) do
  @doc = "Cloudstack Pod"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The pod name"    
  end
  
  newproperty(:zone) do
    desc "The zone that this pod belong to"
  end  
  
  newproperty(:startip) do
    desc "The pod start IP"
  end  
  
  newproperty(:endip) do
    desc "The pod end IP"
  end  
  
  newproperty(:netmask) do
    desc "The pod IP netmask"
  end  
  
  newproperty(:gateway) do
    desc "The pod IP gateway"
  end  
  
  # allocationstate 
end