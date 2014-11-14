# Class: cloudstack
#
# This module manages Apache CloudStack
# It can install the management server, mysql database and NFS server.
#
# Parameters:
#   * cloudstack_server (boolean): Whether to install/configure CloudStack. Default = true
#   * nfs_server (boolean): Whether to install/configure NFS (see README). Default = true
#   * mysql_server (boolean): Whether to install/configure MySQL (see README). Default = true
#   * cloudstack_install (boolean): Whether to install CloudStack. Default = true
#   * cloudstack_install_version (string): CloudStack version to install. Default = 'latest'
#   * cloudstack_mgmt_package_name (string): See Params
#   * cloudstack_yum_repository (string): See Params
#   * cloudstack_apt_repository (string): See Params
#   * cloudstack_apt_release (string): See Params
#   * cloudstack_apt_key    Default = '86C278E3'
#   * cloudstack_apt_keyserver    Default = 'keyserver.ubuntu.com'
#   * vhd_util_url (string): See Params
#   * vhd_util_path (string): See Params
#   * cloudstack_master (boolean): Whether server is the first server installed to use this DB. Default = true
#   * hostname_cloudstack (string): Hostname/IP of Cloudstack Management Server. Default = 'localhost' # TODO ???
#   * hostname_database (string): Hostname/IP of (Master) MySQL Server. Default = 'localhost'
#   * hostname_nfs (string): Hostname/IP of NFS server. Default = 'localhost'
#   * database_username (string): Username for MySQL Database. Default = 'cloudstack'
#   * database_password (string): Password for MySQL Database. REQUIRED (*)
#   * database_server_key (string): Key to protect properties file secrets. REQUIRED (*)
#   * database_database_key (string): Key to protect database secrets. REQUIRED (*)
#   * create_sys_tpl_path (string): See Params
#   * nfs_secondary_storage_mount_dir (string): See Params
#   * hypervisor_support (array): Defines which templates to install on first install.
#     Default: ['hyperv', 'xenserver', 'vmware', 'kvm', 'lxc']
#   * system_template_image_version (string): See Params
#   * system_template_installer_bin (string): See Params
#   * system_template_url (string): See Params
#   * cloudstack_server_count (number): Number of Cloudstack servers to be managed (MySQL setting). Default = 1
#   * mysql_confd_dir (string): See Params
#   * mysql_service_name (string): See Params
#   * nfs_manage_dir (boolean): Whether to manage the parent directory of NFS exports. Default = true
#   * nfs_root_dir (string): Parent directory of NFS exports. Default = '/exports'
#   * nfs_exports (array): Defines all the NFS export targets. Default = ['secondary']
#
# (*) It is highly recommended to put secret keys in Hiera-eyaml and use automatic parameter lookup
# [https://github.com/TomPoulton/hiera-eyaml]
# [https://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup]
#
class cloudstack (
  # Flags to set the deployment scenario
  $cloudstack_server                = true,
  $nfs_server                       = true,
  $mysql_server                     = true,

  # Cloudstack installation flags
  $cloudstack_install               = true,
	$cloudstack_install_version       = 'latest',
	$cloudstack_mgmt_package_name     = $cloudstack::params::cloudstack_mgmt_package_name,
  $cloudstack_yum_repository        = undef,
  $cloudstack_apt_repository        = undef,
  $cloudstack_apt_release           = $cloudstack::params::cloudstack_apt_release,
  $cloudstack_apt_key               = '86C278E3',
  $cloudstack_apt_keyserver         = 'keyserver.ubuntu.com',
  $vhd_util_url                     = $cloudstack::params::vhd_util_url,
  $vhd_util_path                    = $cloudstack::params::vhd_util_path,

  # CloudStack Deployment
  $cloudstack_master                = true,

  $hostname_cloudstack              = 'localhost',
  $hostname_database                = 'localhost',
  $hostname_nfs                     = 'localhost',

  $database_username                = 'cloudstack',
  $database_password,
  $database_server_key,
  $database_database_key,

  $create_sys_tpl_path              = $cloudstack::params::create_sys_tpl_path,
  $nfs_secondary_storage_mount_dir  = $cloudstack::params::nfs_secondary_storage_mount_dir,
  $hypervisor_support               = ['hyperv', 'xenserver', 'vmware', 'kvm', 'lxc'],

  $system_template_image_version    = $cloudstack::params::system_template_image_version,
  $system_template_installer_bin    = $cloudstack::params::system_template_installer_bin,
  $system_template_url              = $cloudstack::params::system_template_url,

  # MySQL Deployment
  $cloudstack_server_count          = 1,
  $mysql_confd_dir                  = $cloudstack::params::mysql_confd_dir,
  $mysql_service_name               = $cloudstack::params::mysql_service_name,

  # NFS Deployment
  $nfs_manage_dir                   = true,
  $nfs_root_dir                     = '/exports',
  $nfs_exports                      = ['secondary'],


  # TODO ? Cloudstack Agent
  #  $cloudstack_agent_package_name  = $cloudstack::params::cloudstack_agent_package_name,
) inherits cloudstack::params {
  # Validation
  validate_string($cloudstack_install_version)

  # Cloudstack Version
  case $cloudstack_install_version {
    'latest': {
      $cloudstack_major_version = '4.4'
    }
    '/^4.0/': {
      $cloudstack_major_version = '4.0'
    }
    '/^4.1/': {
      $cloudstack_major_version = '4.1'
    }
    '/^4.2/': {
      $cloudstack_major_version = '4.2'
    }
    '/^4.3/': {
      $cloudstack_major_version = '4.3'
    }
    '/^4.4/': {
      $cloudstack_major_version = '4.4'
    }
    default: {
      fail('Currently only supports versions 4.0.x - 4.4.x')
    }
  }

  if $cloudstack_yum_repository != undef {
    validate_string($cloudstack_yum_repository)

    $real_cloudstack_yum_repository = $cloudstack_yum_repository
  } else {
    $real_cloudstack_yum_repository = $cloudstack::params::cloudstack_yum_repository_hash[$cloudstack_major_version]
  }

  if $cloudstack_apt_repository != undef {
    validate_string($cloudstack_apt_repository)

    $real_cloudstack_apt_repository = $cloudstack_apt_repository
  } else {
    $real_cloudstack_apt_repository = $cloudstack::params::cloudstack_apt_repository
  }


  # Include and define dependencies
  contain 'cloudstack::install'
  contain 'cloudstack::config'

  Class['cloudstack::install'] -> Class['cloudstack::config']
}
