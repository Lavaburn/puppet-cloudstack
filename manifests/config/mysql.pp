# Class: cloudstack::config::mysql
#
# This is a private class used by the 'cloudstack::config' class.
#
# Configures the MySQL Database
#
class cloudstack::config::mysql (
  $server_count = $cloudstack::cloudstack_server_count,
  $confd_dir    = $cloudstack::mysql_confd_dir,
  $service_name = $cloudstack::mysql_service_name,
) inherits cloudstack::config {
  # Validation
  validate_integer($server_count)

  # Template variable
  $max_connections = $server_count * 350

  if ($confd_dir != false) {
    validate_absolute_path($confd_dir)

    # Configuration file
    file { "${confd_dir}/cloudstack.cnf":
      content => template('cloudstack/cloudstack.cnf.erb'),
    }

    if ($service_name != false) {
      validate_string($service_name)

      File["${confd_dir}/cloudstack.cnf"] ~> Service[$service_name]
    }
  }
}
