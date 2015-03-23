# Custom Type: Cloudstack - Affinity Group

Puppet::Type.newtype(:cloudstack_affinity_group) do
  @doc = "Cloudstack Affinity Group"

  ensurable
        
  newparam(:name, :namevar => true) do
    desc "The affinity group name"
  end
  
  newproperty(:description) do
    desc "The affinity group description"
  end
  
  newproperty(:type) do
    desc "The affinity group type (default: host anti-affinity)"
    defaultto 'host anti-affinity'
  end
  
  newproperty(:account) do
    desc "The account (name)"
  end
  
  #  newproperty(:domainid) do
  #    desc "The account domain ID"
  #  end
    
  newproperty(:domain) do
    desc "The account domain (name)"
  end
end