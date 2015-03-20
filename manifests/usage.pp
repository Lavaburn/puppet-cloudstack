# Class: cloudstack::usage
#
# This will install the Cloudstack Usage Server
#
class cloudstack::usage inherits ::cloudstack {

  Package[$::cloudstack::cloudstack_mgmt_package_name]
  ->
  package { 'cloudstack-usage':
    ensure => 'installed',
  }
  ->
  service { 'cloudstack-usage':
    ensure => 'running',
  }
}
