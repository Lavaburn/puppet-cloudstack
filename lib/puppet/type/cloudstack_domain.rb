# Custom Type: Cloudstack - Domain

Puppet::Type.newtype(:cloudstack_domain) do
  @doc = "Cloudstack Domain"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The domain name (eg. TEST)"    
  end
  
  newproperty(:networkdomain) do
    desc "The domainname (DNS) (eg. test.org) to use when creating VMs under this domain"
  end  
  
  newproperty(:parent) do
    desc "The parent domain (name)"  # CONVERT TO ID
  end  
  
  # domainid [Transfer from other Region ?]
end