# Custom Type: Cloudstack - Cluster

Puppet::Type.newtype(:cloudstack_cluster) do
  @doc = "Cloudstack Cluster"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The name"    
  end
  
  newproperty(:clustertype) do
    desc "The cluster type (CloudManaged, ExternalManaged)"
  end 

  newproperty(:hypervisor) do
    desc "The cluster hypervisor (XenServer,KVM,VMware,Hyperv,BareMetal,Simulator)"
  end 

  newproperty(:pod) do
    desc "The pod that this cluster belongs to"
  end 

  newproperty(:zone) do
    desc "The zone that this cluster belongs to"
  end 
  
  # allocationstate  
  # guestvswitchname - guestvswitchtype 
  # publicvswitchname - publicvswitchtype
  # vsmipaddress - vsmusername - vsmpassword  
  # url - username - password   
end