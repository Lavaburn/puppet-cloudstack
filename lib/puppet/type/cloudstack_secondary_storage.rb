# Custom Type: Cloudstack - Secondary Storage

Puppet::Type.newtype(:cloudstack_secondary_storage) do
  @doc = "Cloudstack Secondary Storage"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The storage unit name"    
  end
  
  newproperty(:zone) do
    desc "The zone that this storage unit belong to"
  end  

  newproperty(:provider) do
    desc "The provider/protocol used to call this storage unit  (NFS/S3/SWIFT/ SMB-CIFS?)"
    defaultto :NFS
  end  
  
  newproperty(:url) do
    desc "The URL to reach/setup the storage unit (nfs://host/path)"
  end  
    
  # UNUSED:
    # details
end