# Custom Type: Cloudstack - Firewall Rule

Puppet::Type.newtype(:cloudstack_firewall_rule) do
  @doc = "Cloudstack Firewall Rule"

  ensurable
      
  newparam(:name, :namevar => true) do
    desc "The Firewall Rule Name"
  end
  
  newparam(:source) do
    desc "The Source IP (CIDR)"
    defaultto '0.0.0.0/0'
  end  
    
  newparam(:publicipaddress) do
    desc "The Public IP Address"
  end  
  
  newparam(:protocol) do
    desc "The protocol (tcp/udp/icmp)"
    defaultto 'tcp'
  end
  
  newparam(:startport) do
    desc "The Start Port (1-65535) [TCP/UDP]"
    defaultto '1'
  end
  
  newparam(:endport) do
    desc "The End Port (1-65535) [TCP/UDP]"
    defaultto '65535'
  end
end