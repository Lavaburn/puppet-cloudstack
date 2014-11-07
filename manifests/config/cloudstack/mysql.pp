# Class: cloudstack::config::cloudstack::mysql
#
#
#
# Parameters:
#   * first_time_setup (boolean): See 'cloudstack::config::cloudstack' class
#   * hostname_nfs (string): See 'cloudstack::config::cloudstack' class
#   * hostname_db (string): See 'cloudstack::config::cloudstack' class
#   * server_key (string): See 'cloudstack::config::cloudstack' class
#   * database_key (string): See 'cloudstack::config::cloudstack' class
#   * database_username (string): See 'cloudstack::config::cloudstack' class
#   * database_password (string): See 'cloudstack::config::cloudstack' class
#   * management_server_ip (string): See 'cloudstack::config::cloudstack' class
#
class cloudstack::config::cloudstack::mysql (
  # User Configuration
  $first_time_setup     = $::cloudstack::config::cloudstack::first_time_setup,
  $hostname_nfs         = $::cloudstack::config::cloudstack::hostname_nfs,
  $hostname_db          = $::cloudstack::config::cloudstack::hostname_db,
  $server_key           = $::cloudstack::config::cloudstack::database_db_key,
  $database_key         = $::cloudstack::config::cloudstack::database_server_key,
  $database_username    = $::cloudstack::config::cloudstack::database_username,
  $database_password    = $::cloudstack::config::cloudstack::database_password,
  $management_server_ip = $::cloudstack::config::cloudstack::management_server_ip,
) {
  # Validation
  validate_bool($first_time_setup)
  validate_string($hostname_nfs, $hostname_db, $server_key, $database_key)
  validate_string($database_username, $database_password, $management_server_ip)

  $bin = '/usr/bin/cloudstack-setup-databases'
  $db = "${database_username}:${database_password}@${hostname_db}"
  $security = "-m ${server_key} -k ${database_key} -i ${management_server_ip}"

  if ($first_time_setup) {
    $deploy = '--deploy-as=root'
  } else {
    $deploy = ''
  }

  exec { 'Setup Cloudstack with MySQL database':
    command     => "${bin} ${db} ${security} ${deploy}",
    # TODO [FEATURE-REQUEST: Install from Source?]
        # What happens if not installed from package??
    subscribe   => Package[$cloudstack::params::cloudstack_package_name],
    refreshonly => true
  }
}
