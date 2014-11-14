# Class: cloudstack::config::cloudstack
#
# This is a private class. Only use the 'cloudstack' class.
#
# Configures CloudStack Instance
#
class cloudstack::config::cloudstack inherits ::cloudstack {
  # Validation
  validate_string($::cloudstack::cloudstack_mgmt_package_name)
  validate_string($::cloudstack::hostname_nfs)
  validate_absolute_path($::cloudstack::create_sys_tpl_path, $::cloudstack::nfs_secondary_storage_mount_dir)
  validate_array($::cloudstack::hypervisor_support)

  # Set-up Cloudstack database (MySQL)
  contain cloudstack::config::cloudstack::mysql

  # Set-up Cloudstack
  Class['cloudstack::config::cloudstack::mysql'] ->
  exec { 'Configure Cloudstack':
    command     => '/usr/bin/cloudstack-setup-management',
    subscribe   => Package[$::cloudstack::cloudstack_mgmt_package_name],
    refreshonly => true,
  }

  if ($::cloudstack::cloudstack_master) {
    # Template Data
    $mount_dir    = $::cloudstack::nfs_secondary_storage_mount_dir
    $hostname_nfs = $::cloudstack::hostname_nfs

    # Create Script
    concat { $::cloudstack::create_sys_tpl_path:
      ensure => present,
    }

    concat::fragment { 'create-sys-tpl-mount':
      target  => $::cloudstack::create_sys_tpl_path,
      content => template('cloudstack/system_template/mount.erb'),
      order   => '10'
    }

    concat::fragment { 'create-sys-tpl-unmount':
      target  => $::cloudstack::create_sys_tpl_path,
      content => template('cloudstack/system_template/unmount.erb'),
      order   => '90'
    }

    cloudstack::config::cloudstack::system_template { $::cloudstack::hypervisor_support:
      script        => $::cloudstack::create_sys_tpl_path,
      image_version => $::cloudstack::system_template_image_version,
      installer_bin => $::cloudstack::system_template_installer_bin,
      directory     => $mount_dir,
      template_url  => $::cloudstack::system_template_url,
    }

    # Run Script
    Exec['Configure Cloudstack']
    ->
    Concat[$::cloudstack::create_sys_tpl_path]
    ->
    exec { 'Install System VM templates':
      command     => "/bin/sh ${::cloudstack::create_sys_tpl_path}",
      subscribe   => Package[$::cloudstack::cloudstack_mgmt_package_name],
      refreshonly => true,
      timeout     => 3600,
    }
  }
}
