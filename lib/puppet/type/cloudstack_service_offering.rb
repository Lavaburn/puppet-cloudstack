# Custom Type: Cloudstack - Service Offering

Puppet::Type.newtype(:cloudstack_service_offering) do
  @doc = "Cloudstack Service Offering"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The service offering name"    
  end
  
  newproperty(:displaytext) do
    desc "The service offering description"
  end  
  
  newproperty(:cpunumber) do
    desc "The number of CPU cores (virtual)"
  end  
  
  newproperty(:cpuspeed) do
    desc "The CPU speed (MHz) (virtual %)"
  end  
  
  newproperty(:memory) do
    desc "The RAM Memory (MB)"
  end  
  
  newproperty(:offerha) do
    desc "Whether to offer High Availability (auto restart)"
    defaultto false
  end  
  
  newproperty(:storagetype) do
    desc "The Storage Type (local/shared)"
    defaultto "local"
  end  
  
  newproperty(:tags, :array_matching => :all) do
    desc "The storage tags (???)"
  end  

  newproperty(:hosttags, :array_matching => :all) do
    desc "The host tags (???)"
  end  

  newproperty(:systemvm) do
    desc "The System VM Type (false, domainrouter, consoleproxy, secondarystoragevm) [false if not a system offering]"
    defaultto false
  end

  # [HYPERVISOR QOS] bytesreadrate (diskBytesReadRate) - byteswriterate (diskBytesWriteRate) - iopsreadrate (diskIopsReadRate) - iopswriterate (diskIopsWriteRate) - customizediops (specify on apply to VM)
  # [STORAGE QOS] miniops - maxiops - customizediops (specify on apply to VM) - hypervisorsnapshotreserve (reserve % of disk for snapshots)
  # networkrate
  # limitcpuuse (don't allow CPU burst)
  # domainid (restrict to domain)
  # deploymentplanner
  # isvolatile (destroys root disk on VM reboot !)
end