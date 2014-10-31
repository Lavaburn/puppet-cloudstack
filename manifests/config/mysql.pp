# Class: cloudstack::config::mysql
#
# Sets up the MySQL Database
#
# Parameters:
#  These flags can be turned off to integrate with other puppet modules.
#   TODO No Flags?
#
# When using the main "cloudstack" class, use Hiera Data Bindings
# to disable the compatibility flags.
#
#  Normal configuration (taken over from cloudstack class)
#   * cloudstack_server_count (string): See 'cloudstack' class
#
class cloudstack::config::mysql (
  # User Configuration
  $cloudstack_server_count  = $::cloudstack::cloudstack_server_count,
) {
  if (!is_numeric($cloudstack_server_count)) {
    fail("cloudstack_server_count should be a number. Set as ${cloudstack_server_count}")
  }

  $max_connections = $cloudstack_server_count * 350

  # TODO Test platform compatibility (Only Ubuntu according to Cloudstack...)
  # TODO What if Mysql::server is not used? (MANUAL INSTALL) ???

  $includedir = '/etc/mysql/conf.d'
  file { "${includedir}/cloudstack.cnf":
    content   => template('cloudstack/cloudstack.cnf.erb'),
    notify    => Service[$mysql::server::server_service_name],
  }#AUTOMATIC ??? -> Class['mysql::server']
}
