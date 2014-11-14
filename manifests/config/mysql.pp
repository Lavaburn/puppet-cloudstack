# Class: cloudstack::config::mysql
#
# This is a private class. Only use the 'cloudstack' class.
#
# Sets up the MySQL Database
#
class cloudstack::config::mysql inherits ::cloudstack {
  # Validation
  if (!is_numeric($::cloudstack::cloudstack_server_count)) {
    fail("cloudstack_server_count should be a number. Set as ${::cloudstack::cloudstack_server_count}")
  }
  validate_absolute_path($::cloudstack::mysql_confd_dir)
  validate_string($::cloudstack::mysql_service_name)

  # Template variables
  $max_connections = $::cloudstack::cloudstack_server_count * 350

  # Configuration file
  file { "${::cloudstack::mysql_confd_dir}/cloudstack.cnf":
    content => template('cloudstack/cloudstack.cnf.erb'),
    notify  => Service[$::cloudstack::mysql_service_name],
  }
}
