# Class: cloudstack::config::cloudstack
#
# Configures CloudStack Instance
#
# Parameters:
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
#   * management_server_ip (string): See 'cloudstack' class
#   * major_version (string): Cloudstack Version (4.0 - 4.4)
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
  $management_server_ip     = $::cloudstack::management_server_ip,

  $major_version            = $::cloudstack::cloudstack_major_version,
) {
  # Validation
  validate_bool($first_time_setup, $create_system_templates)
  validate_array($hypervisor_support)

  # Set-up Cloudstack with MySQL
  class { 'cloudstack::config::cloudstack::mysql':

  }
  ->
  exec { 'Configure Cloudstack':
    command     => '/usr/bin/cloudstack-setup-management',
    # TODO [FEATURE-REQUEST: Install from Source?]
        # What happens if not installed from package??
    subscribe   => Package[$::cloudstack::params::cloudstack_mgmt_package_name],
    refreshonly => true
  }

  if ($first_time_setup and $create_system_templates) {
    # TODO find more permanent path
    $script = '/tmp/create-sys-tpl.sh'

    $mount_dir = '/mnt/secondary'

    concat { $script:
		  ensure => present,
		}

    concat::fragment { 'create-sys-tpl-mount':
		  target  => $script,
		  content => template('cloudstack/system_template/mount.erb'),
		  order   => '10'
		}

		concat::fragment { 'create-sys-tpl-unmount':
      target  => $script,
      content => template('cloudstack/system_template/unmount.erb'),
      order   => '90'
    }

    cloudstack::config::cloudstack::system_template { $hypervisor_support:
      directory       => '/mnt/secondary',
      script          => $script,
      major_version   => $major_version,
    }

    # TODO LOAD TEST MySQL ->  ERROR 1040 (08004): Too many connections
    Concat[$script] ->
    exec { 'Install System VM templates':
      command     => "/bin/sh ${script}",
      subscribe   => Package[$::cloudstack::params::cloudstack_mgmt_package_name],
      refreshonly => true,
      require     => Class['cloudstack::config::cloudstack::mysql'],
    }
  }
}
