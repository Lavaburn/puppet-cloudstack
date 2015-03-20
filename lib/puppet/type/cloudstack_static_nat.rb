# Custom Type: Cloudstack - Static NAT

Puppet::Type.newtype(:cloudstack_static_nat) do
  @doc = "Cloudstack Static NAT"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The name"    
  end
  
  newproperty(:virtual_machine) do
    desc "The Virtual Machine (name)"
  end  
  
  newparam(:ipaddress_id) do
    desc "The Public IP Address ID"
  end
  
  newparam(:virtual_machine_id) do
    desc "The Virtual Machine ID"
  end
end