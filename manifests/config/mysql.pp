# Class: cloudstack::config::mysql
#
# Sets up the MySQL Database
#
# Parameters:
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

  # TODO [FEATURE-REQUEST: Configure without Puppet mysql::server module]
  # => Can't depend on Service['mysqld']

  $includedir = '/etc/mysql/conf.d'
  file { "${includedir}/cloudstack.cnf":
    content   => template('cloudstack/cloudstack.cnf.erb'),
    notify    => Service['mysqld'],
  }
}
