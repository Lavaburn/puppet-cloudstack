# Custom Type: Cloudstack - Domain

Puppet::Type.newtype(:cloudstack_domain) do
  @doc = "Cloudstack Domain"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The domain name (eg. TEST)"    
  end
  
  newproperty(:domain) do
    desc "The domainname (DNS) (eg. test.org) to assign"
  end  
  
  newproperty(:parent) do
    desc "The parent domain (name)"  # CONVERT TO ID
  end  
  
  # domainid [Transfer from other Region ?]
end