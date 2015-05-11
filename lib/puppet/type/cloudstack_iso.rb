# Custom Type: Cloudstack - ISO

Puppet::Type.newtype(:cloudstack_iso) do
  @doc = "Cloudstack ISO"

  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The ISO name"
  end
  
  newproperty(:displaytext) do
    desc "The ISO description"   
  end  
  
  newparam(:url) do
    desc "The url where to download the ISO from"
  end  
  
  newproperty(:zone) do    # ID
    desc "The zone where to register the ISO"               # ALL ZONES ???
  end
  
  newproperty(:bootable) do
    desc "Whether the ISO can be booted from"
  end  
  
  newproperty(:extractable) do
    desc "Whether the ISO can be extracted"
  end  
  
  newproperty(:featured) do
    desc "Whether the ISO is featured"
  end  
  
  newproperty(:public) do
    desc "Whether the ISO is publicly available to all users"
  end 
    
  newproperty(:ostype) do   # ID
    desc "The Operating System Type" 
  end  
  
  newproperty(:account) do
    desc "Assign the ISO to a specific account"
  end 
  
  newproperty(:domain) do  # ID
    desc "The domain that the account (ISO owner) belongs to"
  end 
    
#  newparam(:project) do   # ID
#    desc "Assign the ISO to a specific project"
#  end    
    
  # UNUSED: 
    # checksum, imagestoreuuid, isdynamicallyscalable
end