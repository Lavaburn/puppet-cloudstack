# Custom Type: Cloudstack - Resource Limit

Puppet::Type.newtype(:cloudstack_resource_limit) do
  @doc = "Cloudstack Resource Limit"

  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The Resource Limit ID - Format: type_account@domain or type_domain"
  end
  
  newparam(:type) do
    desc "The limit type: instance/ip/volume/snapshot/template/network/vpc/cpu/memory/primarystorage/secondarystorage"   
  end  
  
  newproperty(:max) do
    desc "The maximum value"
  end  
  
  newparam(:account) do
    desc "The account to which the limits apply"
  end  
   
  newparam(:domain) do   # ID
    desc "The domain to which the account belongs, or (if not set) to which the limits apply"
  end  
end 
