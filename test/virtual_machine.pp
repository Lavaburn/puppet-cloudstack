#cloudstack_virtual_machine { 'affinitytest1':
#  ensure          => 'absent',
#  account         => 'JUBANOC',
#  domain          => 'RCS',
#  zone            => 'Juba-TWR1',
#  serviceoffering => 'Large',
#  template        => 'Ubuntu 14.04.2 (XenServer)',
#  default_network => 'RCS Public Services',
#  userdata        => 'server=A,environment=B',
#  keypair         => 'admin-created',
#  affinitygroups  => ['affinity1', 'affinity2']
#}

#cloudstack_ssh_keypair { 'admin-created':
#  ensure    => 'absent',
#}

#cloudstack_public_ip { 'RCS Public Services':
#  ensure  => 'present',
#  count   => '3'
#}

#cloudstack_static_nat { '105.235.209.16':
#  ensure          => 'present',
#  virtual_machine => 'test2'
#}

#cloudstack_affinity_group { 'affinity1':
#  ensure      => 'absent',
#  description => 'First Affinity',
#}

#cloudstack_affinity_group { 'affinity2':
#  ensure      => 'absent',
#  description => 'Second Affinity',
#}

#cloudstack_firewall_rule { '0.0.0.0/0_105.235.209.21_tcp_1':
#  ensure          => absent,
#  source          => '0.0.0.0/0',
#  publicipaddress => '105.235.209.21',
#  protocol        => 'tcp',
#  startport       => '1',
#  endport         => '65535',
#}
#
#cloudstack_firewall_rule { '0.0.0.0/0_105.235.209.21_icmp':
#  ensure          => absent,
#  source          => '0.0.0.0/0',
#  publicipaddress => '105.235.209.21',
#  protocol        => 'icmp',
#}
#
#cloudstack_zone { 'TESTZONE1':
#  ensure           => present,
#  networktype      => 'Advanced',
#  dns1             => '208.67.222.222',
#  dns2             => '8.8.4.4',
#  internaldns1     => '41.207.96.71',
#  internaldns2     => '41.207.96.72',
#  networkdomain    => 'test1.rcswimax.com',
#  guestcidraddress => '172.20.111.0/24',
#}
#
#cloudstack_pod { 'TESTPOD1':
#  ensure  => present,
#  zone    => 'TESTZONE1',
#  startip => '172.20.112.100',    # NOT the same as guestcidraddress !!!
#  endip   => '172.20.112.200',
#  netmask => '255.255.255.0',
#  gateway => '172.20.112.3',
#}

cloudstack_cluster { 'TESTCLUSTER1':
  ensure      => present,
  clustertype => 'CloudManaged',
  hypervisor  => 'XenServer',
  zone        => 'TESTZONE1',
  pod         => 'TESTPOD1',
}

#cloudstack_domain { 'RCS':
#  ensure        => present,
#  networkdomain => 'rcswimax.com',
#}
#
#cloudstack_account { 'JUBANOC':
#  ensure        => enabled,
#  accounttype   => 'domain-admin',  # admin is only possible in ROOT domain ?
#  domain        => 'RCS',
#  networkdomain => 'juba.rcswimax.com',
#
#  # Create Only !
#  username      => 'nicolas',
#  firstname     => 'Nicolas',
#  lastname      => 'Truyens',
#  email         => 'nicolas@truyens.com',
#  password      => 'password',    # HIERA !
#}

#cloudstack_user { 'henry':
#  ensure      => absent,
#  account     => 'JUBANOC',
#  domain      => 'RCS', # Tight-Coupling to Account
#  firstname   => 'Henry',
#  lastname    => 'Mwanzia',
#  email       => 'henry@rcswimax.com',
#  password    => 'secret',
#}

#cloudstack_service_offering { 'Small':
#  ensure      => absent,
#  displaytext => 'Small - 1 Core, 1 GB',
#  cpunumber   => '1',
#  cpuspeed    => '1000',
#  memory      => '1024',
#  offerha     => false,
#  storagetype => 'local',
#  tags        => ['stag1', 'stag2'],
#  hosttags    => 'htag2',
#}

#cloudstack_service_offering { 'Larger System Router':
#  ensure      => absent,
#  displaytext => 'Larger System Router - 1 Core, 512 MB :-)',
#  cpunumber   => '1',
#  cpuspeed    => '1000',
#  memory      => '512',
#  offerha     => true,
#  storagetype => 'shared',
#  tags        => 'stag1_sys',
#  hosttags    => 'htag2_sys',
#  systemvm    => 'domainrouter',
#}

#cloudstack_disk_offering { 'Standard_50GB':
#  ensure      => absent,
#  displaytext => '50 GB Standard',
#  storagetype => 'shared',
#  disksize    => '50',
#  tags        => ['std'],
#}

#cloudstack_network_offering { 'FullFeature_TEST':
#  ensure              => 'enabled',
#  displaytext         => 'Enabled ALL services',
#  guestiptype         => 'isolated',
#  ispersistent        => true,
#  conservemode        => true,
#  availability        => 'Optional',    # Can't be required without SourceNat     # System can only have 1 with Required !
#  specifyvlan         => true,
#  specifyipranges     => false,         # can't be true if SourceNat
#  egressdefaultpolicy => true,
#  serviceoffering     => 'System Offering For Software Router',
#  tags                =>  ['testnet'],
#  service             => [
#    {
#      name     => 'Vpn',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'Dhcp',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'Dns',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'Firewall',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'Lb',# Load Balancer
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'UserData',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'SourceNat',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'StaticNat',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }, {
#      name     => 'PortForwarding',
#      provider => [
#        {
#          name => 'VirtualRouter'
#        }]
#    }
#  ]
#}










  #  createStoragePool
  #  addImageStore




  #  createVlanIpRange



  #  createNetwork

  #  addHost (XenServer => Razor => Exported Resource??)

  #  createTemplate
  #  registerIso

  # Snapshots (recurring?))
