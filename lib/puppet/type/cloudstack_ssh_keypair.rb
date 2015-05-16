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
  
  newproperty(:domain) do   # ID
    desc "The account domain (name)"
  end
  
  newparam(:publickey) do
    desc "The Public Key (string)"
  end
  
  # UNUSED
    # projectid
end