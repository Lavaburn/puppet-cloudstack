# Custom Type: Cloudstack - Configuration

Puppet::Type.newtype(:cloudstack_configuration) do
  @doc = "Cloudstack Configuration"

  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The configuration ID - Format: scope_scopename_name. eg. cluster_testcluster_cpu.overprovisioning.factor"
    # Scope = cluster, account, storagepool, zone, global
  end
  
  newparam(:configuration_name) do
    desc "The real config name"   
  end  
  
  newproperty(:value) do
    desc "The value"
  end  
  
  newparam(:zone) do      # ID
    desc "SCOPE=ZONE; The zone to which the config applies"
  end
  
  newparam(:cluster) do   # ID
    desc "SCOPE=CLUSTER; The cluster to which the config applies"
  end 
  
  newparam(:storage) do  # ID
    desc "SCOPE=STORAGE; The primary storage pool to which the config applies"
  end 
    
  newparam(:account) do   # ID
    desc "SCOPE=ACCOUNT; The account to which the config applies"
  end   
end