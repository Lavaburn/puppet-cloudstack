# Class: cloudstack::config::cloudstack::mysql
#
# This is a private class used by the 'cloudstack::config::cloudstack' class.
#
# This class sets up the MySQL database for the first time
#
class cloudstack::config::cloudstack::mysql (
  $setup_db_bin = $cloudstack::cloudstack_setup_db_bin,

  $is_master = $cloudstack::cloudstack_master,

  $cloudstack_hostname = $cloudstack::hostname_cloudstack,
  $db_hostname         = $cloudstack::hostname_database,

  $db_username     = $cloudstack::database_username,
  $db_password     = $cloudstack::database_password,
  $db_server_key   = $cloudstack::database_server_key,
  $db_database_key = $cloudstack::database_database_key,
) inherits cloudstack::config::cloudstack {
  # Validation
  validate_absolute_path($setup_db_bin)
  validate_bool($is_master)
  validate_string($db_hostname, $cloudstack_hostname)
  validate_string($db_username, $db_password)
  validate_string($db_server_key, $db_database_key)

  # Command Parameters
  $db = "${db_username}:${db_password}@${db_hostname}"
  $security = "-m ${db_server_key} -k ${db_database_key} -i ${cloudstack_hostname}"
  if ($is_master) {
    $deploy = '--deploy-as=root'
  } else {
    $deploy = ''
  }

  # Execute Database Initialisation if DB 'cloud' does not exist
  exec { 'Setup Cloudstack with MySQL database':
    command => "${setup_db_bin} ${db} ${security} ${deploy}",
    unless  => "/usr/bin/mysql -h${db_hostname} -u${db_username} -p${db_password} cloud",
  } ~> Anchor['cloudstack_first_time_config_step_1']
}
