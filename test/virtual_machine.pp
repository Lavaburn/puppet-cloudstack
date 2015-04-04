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




# LONG TERM:
  #  createZone
  #  createPod

  #  createNetwork
  #  createStoragePool
  #  addImageStore

  #  addCluster
  #  addHost (XenServer => Razor => Exported Resource??)

  #  createVlanIpRange

  #  createServiceOffering
  #  createNetworkOffering
  #  createDiskOffering

  #  createDomain
  #  createAccount
  #  createUser

  #  createTemplate
  #  registerIso

    # Snapshots (recurring?))
