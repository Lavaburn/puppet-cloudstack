# Custom Type: Cloudstack - SSH Keypair

Puppet::Type.newtype(:cloudstack_ssh_keypair) do
  @doc = "Cloudstack SSH Keypair"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The name"    
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
  
  # TODO
  #  projectid      list objects by project

  newparam(:publickey) do
    desc "The Public Key (string)"
  end
end