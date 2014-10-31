# Class: cloudstack::config::cloudstack
#
# Configures CloudStack Instance
#
# Parameters:
#  These flags can be turned off to integrate with other puppet modules.
#   TODO No Flags?
#
# When using the main "cloudstack" class, use Hiera Data Bindings
# to disable the compatibility flags.
#
#  Normal configuration (taken over from cloudstack class)
#   * first_time_setup (boolean): See 'cloudstack' class
#   * create_system_templates (boolean): See 'cloudstack' class
#   * hostname_nfs (boolean): See 'cloudstack' class
#   * hostname_db (boolean): See 'cloudstack' class
#   * hypervisor_support (array): See 'cloudstack' class
#   * database_server_key (string): See 'cloudstack' class
#   * database_db_key (string): See 'cloudstack' class
#   * database_username (string): See 'cloudstack' class
#   * database_password (string): See 'cloudstack' class
#
class cloudstack::config::cloudstack (
  $first_time_setup         = $::cloudstack::first_time_setup,
  $create_system_templates  = $::cloudstack::create_system_templates,
  $hostname_nfs             = $::cloudstack::hostname_nfs,
  $hostname_db              = $::cloudstack::hostname_db,
  $hypervisor_support       = $::cloudstack::cloudstack_hypervisor_support,
  $database_server_key      = $::cloudstack::database_server_key,
  $database_db_key          = $::cloudstack::database_db_key,
  $database_username        = $::cloudstack::database_username,
  $database_password        = $::cloudstack::database_password,
) {
  # Validation
  validate_bool($first_time_setup, $create_system_templates)
  validate_array($hypervisor_support)

  if ($first_time_setup and $create_system_templates) {
    file { '/mnt/secondary':
      ensure => 'directory',
    } ->

    # TODO NFS MOUNT
    # BEFORE: Mount
    #  mkdir -p /mnt/secondary
    #  mount -t nfs <NFS_SERVER>:/nfs/share/secondary /mnt/secondary

    cloudstack::config::cloudstack::system_template { $hypervisor_support:
      directory => '/mnt/secondary',
    }

    # AFTER
    #  umount /mnt/secondary
    #  rm -rf /mnt/secondary
  }

  # Set-up Cloudstack with MySQL
  class { 'cloudstack::config::cloudstack::mysql':

  }
  ->
  exec { 'Configure Cloudstack':
    command     => "/usr/bin/cloudstack-setup-management",
    subscribe   => Package[$cloudstack::params::cloudstack_package_name], # TODO What happens if not installed from package??
    refreshonly => true
  }
}
