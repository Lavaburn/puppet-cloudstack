# Custom Type: Cloudstack - Secondary Staging Storage

Puppet::Type.newtype(:cloudstack_secondary_staging_storage) do
  @doc = "Cloudstack Secondary Staging Storage"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The storage unit name = URL"    
  end
  
  newproperty(:zone) do
    desc "The zone that this storage unit belong to"
  end  

  newproperty(:provider) do
    desc "The provider/protocol used to call this storage unit  (NFS ONLY?)"
    defaultto :NFS
  end  
  
  newproperty(:url) do # Should be the namevar ???
    desc "The URL to reach/setup the storage unit (nfs://host/path)"
  end  
    
  # UNUSED:
    # details
    # scope (ZONE ONLY !)
end