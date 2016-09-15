# Class: cloudstack::config::cloudstack
#
# This is a private class used by the 'cloudstack::config' class.
#
# First-Time configuration of the CloudStack Instance
#
class cloudstack::config::cloudstack (
  $setup_mgmt_bin        = $cloudstack::cloudstack_setup_mgmt_bin,
  $sys_tpl_installer_bin = $cloudstack::sys_tpl_installer_bin,
  $installer_scripts_dir = $cloudstack::cloudstack_installer_scripts_dir,

  $is_master             = $cloudstack::cloudstack_master,
  $nfs_hostname          = $cloudstack::hostname_nfs,

  $hypervisor_support    = $cloudstack::hypervisor_support,
  $sys_tpl_url           = $cloudstack::sys_tpl_url,
  $version               = $cloudstack::cloudstack_version,
) inherits cloudstack::config {
  # Validation
  validate_absolute_path($setup_mgmt_bin, $installer_scripts_dir, $sys_tpl_installer_bin)
  validate_bool($is_master)
  validate_string($nfs_hostname, $sys_tpl_url, $version)
  validate_array($hypervisor_support)

  # Trigger Sequence
  anchor { 'cloudstack_first_time_config_step_1': }
  anchor { 'cloudstack_first_time_config_step_2': }

  # First Time Configuration - Step 1 - MySQL Database Setup
  contain cloudstack::config::cloudstack::mysql

  # First Time Configuration - Step 2 - Setup Mgmt Server
  exec { 'Configure Cloudstack':
    command     => $setup_mgmt_bin,
    refreshonly => true,
    subscribe   => Anchor['cloudstack_first_time_config_step_1'],
  } ~> Anchor['cloudstack_first_time_config_step_2']

  # First Time Configuration - Step 3 - Setup System Templates
  if ($is_master) {
    # Create Script
    $script = "${installer_scripts_dir}/create-sys-tpl.sh"

    concat { $script:
      ensure => 'present',
    }

    # Mount/unmount NFS
    $mount_dir = '/mnt/cloudstack_secondary_storage'

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

    # Install System Template for Hypervisor
    cloudstack::config::cloudstack::system_template { $hypervisor_support:
      script         => $script,
      installer_bin  => $sys_tpl_installer_bin,
      directory      => $mount_dir,
      base_url       => $sys_tpl_url,
      server_version => $version,
    }

    # Run Script
    Concat[$script]
    ->
    exec { 'Install System VM templates':
      command     => "/bin/sh ${script}",
      refreshonly => true,
      subscribe   => Anchor['cloudstack_first_time_config_step_2'],
      timeout     => 3600,
    }
  }
}
