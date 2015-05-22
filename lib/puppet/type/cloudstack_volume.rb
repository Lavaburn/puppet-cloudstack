# Custom Type: Cloudstack - Volume

Puppet::Type.newtype(:cloudstack_volume) do
  @doc = "Cloudstack Volume"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The volume name"    
  end
  
  newproperty(:diskoffering) do     # ID
    desc "The disk offering"
  end 
  
  newproperty(:snapshot) do     # ID
    desc "The snapshot ?"
  end 

  newproperty(:zone) do     # ID
    desc "The zone that this volume belongs to"
  end 
  
  newproperty(:account) do
    desc "The account that this volume belongs to"
  end 

  newproperty(:domain) do   # ID
    desc "The domain of the account that this volume belongs to"
  end 
  
  newproperty(:virtualmachine) do   # ID
    desc "The virtual machine to which to attach the volume"
  end 
    
  # UNUSED:
    # miniops - maxiops
    # size (custom disk offering?)
    # displayvolume
    # customid
    # projectid
end