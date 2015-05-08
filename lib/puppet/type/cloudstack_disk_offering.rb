# Custom Type: Cloudstack - Disk Offering

Puppet::Type.newtype(:cloudstack_disk_offering) do
  @doc = "Cloudstack Disk Offering"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The disk offering name"    
  end

  newproperty(:displaytext) do
    desc "The disk offering description"
  end  

  newproperty(:storagetype) do
    desc "The Storage Type (local/shared)"
    defaultto "local"
  end  
  
  newproperty(:disksize) do
    desc "The disk size (GB)"
  end  

  newproperty(:tags, :array_matching => :all) do
    desc "The storage tags (???)"
  end  
  
  
  # customized (User can specify size on VM assignment)  
  # [HYPERVISOR QOS]  bytesreadrate - byteswriterate - iopsreadrate - iopswriterate
  # [STORAGE QOS]     customizediops - miniops - maxiops - hypervisorsnapshotreserve
  # domainid (restrict to domain)
  # displayoffering (End-user visible ???)
end