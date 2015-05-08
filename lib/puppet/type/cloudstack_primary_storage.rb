# Custom Type: Cloudstack - Primary Storage

Puppet::Type.newtype(:cloudstack_primary_storage) do
  @doc = "Cloudstack Primary Storage"

  ensurable   # TODO MAINTENANCE !!!
      
  newparam(:name, :namevar => true) do
    desc "The storage unit name"    
  end
  
  newproperty(:scope) do
    desc "The scope of this storage unit (zone/cluster)"
  end  
  
  newproperty(:zone) do
    desc "The zone that this storage unit belong to"
  end  
  
  newproperty(:pod) do
    desc "The pod that this storage unit belong to [Scope=Cluster]"
  end  
  
  newproperty(:cluster) do
    desc "The cluster that this storage unit belong to [Scope=Cluster]"
  end  
  
  newproperty(:hypervisor) do
    desc "The hypervisor type that this storage unit can be used by (KVM/VMWare/Hyperv) [Scope=Zone]"
  end  
  
  newproperty(:url) do
    desc "The URL to reach/setup the storage unit (nfs://host/path ; presetup://localhost/label ; iscsi://IQN?)"
  end  
  
  newproperty(:tags, :array_matching => :all) do
    desc "The storage tags"
  end  
  
  # UNUSED:
  # capacitybytes - capacityiops
  # details - managed
end