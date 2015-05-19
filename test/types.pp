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

#cloudstack_ssh_keypair { 'KEY1':
#  ensure    => 'absent',
#}
#
#cloudstack_ssh_keypair { 'KEY2':
#  ensure    => 'absent',
#  publickey => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZaQOkPRdC0rM30+/WSIlVK+YxSfI0fyIHM+FsXXxMzPTWWBpGcboxD4uDeZi1gpPtsl8ZYj0i/WN+nksVQQHLfd8/e2Xz9gueVECV22YhnusF1Ri+d7O14VBufJ0LBD8zzI6/2NrIp89rz0rcDED9BaANa9XL3pohdUd06tdXtFgqol9yez5H/Cu/ugdaBzGEVPadqb4G+1ZXmiefSTzEhbHT1LDKwWjtn5yyXkQpVFcGkKmDCrQoW1Z6j3SW4NsXNd4dGpVVSNa1hdlMjJPK9/KzPPgw9sPZZeWCPRlqzKHEJcAxrMArpGaYGk1guXe80Yhd7Fp6cUxbWVQOCHtD nicolas@Lava-PC',
#}
#
#cloudstack_ssh_keypair { 'KEY3':
#  ensure    => 'absent',
#  account   => 'JUBANOC',
#  domain    => 'RCS',
#}
#
#cloudstack_ssh_keypair { 'KEY4':
#  ensure    => 'absent',
#  publickey => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZaQOkPRdC0rM30+/WSIlVK+YxSfI0fyIHM+FsXXxMzPTWWBpGcboxD4uDeZi1gpPtsl8ZYj0i/WN+nksVQQHLfd8/e2Xz9gueVECV22YhnusF1Ri+d7O14VBufJ0LBD8zzI6/2NrIp89rz0rcDED9BaANa9XL3pohdUd06tdXtFgqol9yez5H/Cu/ugdaBzGEVPadqb4G+1ZXmiefSTzEhbHT1LDKwWjtn5yyXkQpVFcGkKmDCrQoW1Z6j3SW4NsXNd4dGpVVSNa1hdlMjJPK9/KzPPgw9sPZZeWCPRlqzKHEJcAxrMArpGaYGk1guXe80Yhd7Fp6cUxbWVQOCHtD nicolas@Lava-PC',
#  account   => 'JUBANOC',
#  domain    => 'RCS',
#}

#cloudstack_public_ip { 'RCS Services':
#  ensure  => 'absent',
#  count   => '1'
#}

#cloudstack_static_nat { '105.235.209.16':
#  ensure          => 'present',
#  virtual_machine => 'test2'
#}

#cloudstack_affinity_group { 'affinity1':
#  ensure      => 'absent',
#  description => 'First Affinity',
#  account     => 'JUBANOC',
#  domain      => 'RCS',
#}

#cloudstack_affinity_group { 'affinity2':
#  ensure      => 'absent',
#  description => 'Second Affinity',
##  account     => 'JUBANOC',
##  domain      => 'RCS',
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

#cloudstack_pod { 'TESTPOD1':
#  ensure  => present,
#  zone    => 'TESTZONE1',
#  startip => '172.20.130.200',    # Reserved/Used by System VMs (Secondary Storage, Router?) [OUTSIDE RAZOR DHCP]
#  endip   => '172.20.130.240',
#  netmask => '255.255.255.0',
#  gateway => '172.20.130.1',      # Should be in same network as the Hypervisors !! (MANAGEMENT VLAN)
#}

#cloudstack_cluster { 'TESTCLUSTER1':
#  ensure      => present,
#  clustertype => 'CloudManaged',
#  hypervisor  => 'XenServer',
#  zone        => 'TESTZONE1',
#  pod         => 'TESTPOD1',
#}
#
#cloudstack_domain { 'RCS':
#  ensure        => absent,
#  networkdomain => 'rcswimax.com',
#}
#
#cloudstack_account { 'JUBANOC':
#  ensure        => absent,
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
#  ensure      => present,
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

#cloudstack_primary_storage { 'TEST-Xen-LOCAL':
#  ensure        => present,
#  scope         => 'cluster',
#  zone          => 'TESTZONE1',
#  pod           => 'TESTPOD1',
#  cluster       => 'TESTCLUSTER1',
#  #hypervisor    => '',
#  url           => 'PreSetup://localhost/Xen-PV1',
#  tags          => ['SAS'],
#}

#cloudstack_secondary_storage { 'MyTemplatesTest':
#  ensure => absent,
#  zone   => 'TESTZONE1',
#  url    => 'nfs://172.20.0.1/mytemplates',
#}
#
#cloudstack_secondary_storage { 'Cloudstack_Temporary':
#  ensure => present,
#  zone   => 'TESTZONE1',
#  url    => 'nfs://172.20.130.3/secondary',
#}

#cloudstack_secondary_staging_storage { 'nfs://172.20.0.2/mystaging':
#  ensure => absent,
#  zone   => 'TESTZONE1',
#  url    => 'nfs://172.20.0.2/mystaging',
#}

#cloudstack_physical_network { 'TEST_PHY_NET1':
#  ensure           => enabled,
#  zone             => 'TESTZONE1',
#  # domain          => 'RCS',
#  isolationmethods => 'VLAN',
#  vlan             => '3030-3039',
#  tags             => ['physical1'],
#}

#cloudstack_traffic_type { 'TEST_PHY_NET1_Guest':
#  physicalnetwork => 'TEST_PHY_NET1',
#  traffictype     => 'Guest',
#  label           => 'Private',
#}
#
#cloudstack_traffic_type { 'TEST_PHY_NET1_Management':
#  physicalnetwork => 'TEST_PHY_NET1',
#  traffictype     => 'Management',
#  label           => 'BOND',
#}
#
#cloudstack_traffic_type { 'TEST_PHY_NET1_Storage':
#  physicalnetwork => 'TEST_PHY_NET1',
#  traffictype     => 'Storage',
#  label           => 'SAN',
#}
#
#cloudstack_traffic_type { 'TEST_PHY_NET1_Public':
#  physicalnetwork => 'TEST_PHY_NET1',
#  traffictype     => 'Public',
#  label           => 'Public',
#}

## Public IP for System Routers
#cloudstack_network_vlan { 'TEST_PHY_NET1_3011_105.235.209.130':
#  ensure           => present,
#  vlan             => '3011',
#  zone             => 'TESTZONE1',
#	startip          => '105.235.209.130',
#	endip            => '105.235.209.140',
#	netmask          => '255.255.255.128',
#	gateway          => '105.235.209.129',
#	physicalnetwork  => 'TEST_PHY_NET1',
#}

## Public IP for VMs
#cloudstack_network_vlan { 'TEST_PHY_NET1_3011_105.235.209.141':
#  ensure           => absent,
#  vlan             => '3011',
#  zone             => 'TESTZONE1',
#  account          => 'JUBANOC',
#  domain           => 'RCS',
#  startip          => '105.235.209.141',
#  endip            => '105.235.209.160',
#  netmask          => '255.255.255.128',
#  gateway          => '105.235.209.129',
#  physicalnetwork  => 'TEST_PHY_NET1',
#}

#cloudstack_network_storage_vlan { 'TESTPOD1_172.20.141.10':
#  ensure           => absent,
#  vlan             => '3021',
#  startip          => '172.20.141.10',
#  endip            => '172.20.141.20',
#  netmask          => '255.255.255.0',
#  gateway          => '172.20.141.1',
#  pod              => 'TESTPOD1',
#}

#cloudstack_virtual_router_element { 'TEST_PHY_NET1_VirtualRouter':
#  ensure           => enabled,
#  physicalnetwork  => 'TEST_PHY_NET1',
#  providertype     => 'VirtualRouter',
#}
#
#cloudstack_network_provider { 'TEST_PHY_NET1_VirtualRouter':
#  ensure           => enabled,
#  physicalnetwork  => 'TEST_PHY_NET1',
#  service_provider => 'VirtualRouter',
#}

#cloudstack_network { 'TEST1':
#  ensure           => absent,
#  displaytext      => 'API TEST Network #1',
#  networkoffering  => 'RCS_Juba_Network_Full_Feature',       # Type = Shared defined in this offering - Needs to support Dhcp
#  zone             => 'Juba-TWR1',
#  # physicalnetwork  => '',                                   # Only for type = Shared !!
#  vlan             => '3152',
##  startip          => '172.20.112.10',    # TODO UNUSED for Isolated ??
##  endip            => '172.20.112.100',   # TODO UNUSED for Isolated ??
#  netmask          => '255.255.255.0',
#  gateway          => '172.20.112.1',
#  account          => 'JUBANOC',
#  domain           => 'RCS',
#  networkdomain    => 'test1.twr1.rcswimax.com',
#}

#cloudstack_guest_vlan { '3032-3033':    # Fits in range set on Physical Network !!
#  ensure            => present,
#  physicalnetwork   => 'TEST_PHY_NET1',
#  account           => 'JUBANOC',
#  domain            => 'RCS',
#}

#cloudstack_host { 'hypervisor3.rcswimax.com':
#  ensure      => enabled,
#  ipaddress   => '172.20.130.83',
#  username    => 'root',
#  password    => 'xenserver',
#  hypervisor  => 'XenServer',
#  cluster     => 'TESTCLUSTER1',
#  zone        => 'TESTZONE1',
#  pod         => 'TESTPOD1',
#  tags        => ['deltas'],
#}    # XenServer::install => Exported Resource !!

#cloudstack_volume { 'TEST_DATADISK':
#  ensure          => absent,
#  diskoffering    => 'Standard_50GB',
#  zone            => 'TESTZONE1',
#}

#cloudstack_iso { 'Ubuntu 14.04.2 LTS':
#  ensure        => present,
#  displaytext   => 'Ubuntu 14.04.2 LTS (Trusty Tahr)',
#  url           => 'http://releases.ubuntu.com/14.04.2/ubuntu-14.04.2-server-amd64.iso',
#  zone          => 'TESTZONE1',
#  bootable      => true,
#  extractable   => false,
#  featured      => true,
#  public        => true,
#  ostype        => 'Other Linux (64-bit)',
#}

#cloudstack_configuration { 'account_JUBANOC_use.system.guest.vlans':
#  configuration_name => 'use.system.guest.vlans',
#  value              => 'false',
#  account            => 'JUBANOC',
#}
#
#cloudstack_configuration { 'account_JUBANOC_use.system.public.ips':
#  configuration_name => 'use.system.public.ips',
#  value              => 'false',
#  account            => 'JUBANOC',
#}
#
#cloudstack_configuration { 'cluster_TESTCLUSTER1_cpu.overprovisioning.factor':
#  configuration_name => 'cpu.overprovisioning.factor',
#  value              => '4.0',
#  cluster            => 'TESTCLUSTER1',
#}
#
##cloudstack_configuration { 'storagepool_TEST-Xen-LOCAL_storage.overprovisioning.factor':
##  configuration_name => 'storage.overprovisioning.factor',
##  value              => '1.0',
##  storage            => 'TEST-Xen-LOCAL',
##}
#
#cloudstack_configuration { 'zone_TESTZONE1_guest.domain.suffix':
#  configuration_name => 'guest.domain.suffix',
#  value              => 'zone1.rcswimax.com',
#  zone               => 'TESTZONE1',
#}
#
#cloudstack_configuration { 'global_max.account.primary.storage':
#  configuration_name => 'max.account.primary.storage',   # DEFAULTS - BEFORE ACCOUNT CREATION !!!
#  value              => '1000',
#}

#cloudstack_resource_limit { 'ip_JUBANOC@RCS':
#  type    => ip,
#  account => 'JUBANOC',
#  domain  => 'RCS',
#  max     => '32',
#}
