# Class: cloudstack::config::cloudstack::mysql
#
# This is a private class. Only use the 'cloudstack' class.
#
# This class sets up the MySQL database for the first time
#
class cloudstack::config::cloudstack::mysql inherits ::cloudstack {
  # Validation
  validate_bool($::cloudstack::cloudstack_master)
  validate_string($::cloudstack::hostname_database, $::cloudstack::hostname_cloudstack)
  validate_string($::cloudstack::database_server_key, $::cloudstack::database_database_key)
  validate_string($::cloudstack::database_username, $::cloudstack::database_password)
  validate_string($::cloudstack::cloudstack_mgmt_package_name)

  $bin = '/usr/bin/cloudstack-setup-databases'
  $db = "${::cloudstack::database_username}:${::cloudstack::database_password}@${::cloudstack::hostname_database}"
  $security = "-m ${::cloudstack::database_server_key} -k ${::cloudstack::database_database_key} -i ${::cloudstack::hostname_cloudstack}"

  if ($::cloudstack::cloudstack_master) {
    $deploy = '--deploy-as=root'
  } else {
    $deploy = ''
  }

  # TODO [FEATURE-REQUEST: Install from Source?]
  # => Can't depend on Package['cloudstack-management']

  exec { 'Setup Cloudstack with MySQL database':
    command     => "${bin} ${db} ${security} ${deploy}",
    subscribe   => Package[$::cloudstack::cloudstack_mgmt_package_name],
    refreshonly => true,
  }
}
