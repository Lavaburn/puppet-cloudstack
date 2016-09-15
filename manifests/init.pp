# Class: cloudstack
#
# This module manages Apache CloudStack
# It can install the management server, mysql database and NFS server.
#
# Parameters:
#   * cloudstack_server (boolean): Whether to install/configure CloudStack. Default = true
#   * nfs_server (boolean): Whether to install/configure NFS (see README). Default = true
#   * mysql_server (boolean): Whether to install/configure MySQL (see README). Default = true
#   * cloudstack_version (string): See Params
#   * cloudstack_setup_repos (boolean): Whether to setup CloudStack repository (Apt/Yum). Default = true
#   * cloudstack_install_mgmt (boolean): Whether to install CloudStack Management Server. Default = true
#   * cloudstack_mgmt_package_name (string): See Params
#   * cloudstack_mgmt_service_name (string): See Params
#   * cloudstack_install_usage (boolean): Whether to install CloudStack Usage Server. Default = false
#   * cloudstack_usage_package_name (string): See Params
#   * cloudstack_usage_service_name (string): See Params
#   * vhd_util_url (string): See Params
#   * vhd_util_path (string): See Params
#   * cloudstack_setup_dir (absolute path): See Params
#   * cloudstack_installer_scripts_dir (absolute path): See Params
#   * cloudstack_setup_db_bin (absolute path): See Params
#   * cloudstack_setup_mgmt_bin (absolute path): See Params
#   * cloudstack_master (boolean): Whether server is the first server installed to use this DB. Default = true
#   * hostname_cloudstack (string): Hostname/IP of Cloudstack Management Server. Default = 'localhost'
#   * hostname_database (string): Hostname/IP of (Master) MySQL Server. Default = 'localhost'
#   * hostname_nfs (string): Hostname/IP of NFS server. Default = 'localhost'
#   * database_username (string): Username for MySQL Database. Default = 'cloudstack'
#   * database_password (string): Password for MySQL Database.
#   * database_server_key (string): Key to protect properties file secrets.
#   * database_database_key (string): Key to protect database secrets.
#   * hypervisor_support (array): Defines which templates to install on first install.
#     Default: ['hyperv', 'xenserver', 'vmware', 'kvm', 'lxc']
#   * sys_tpl_installer_bin (absolute path): See Params
#   * sys_tpl_url (string): See Params
#   * cloudstack_server_count (number): Number of Cloudstack servers to be managed (MySQL setting). Default = 1
#   * mysql_confd_dir (absolute path): See Params
#   * mysql_service_name (string): See Params
#   * nfs_manage_dir (boolean): See Params
#   * nfs_root_dir (absolute path): See Params
#   * nfs_export_clients (string): See Params
#   * nfs_exports (array): Defines all the NFS export targets. Default = ['secondary']
#
class cloudstack (
  # Flags to set the deployment scenario
  $cloudstack_server = true,
  $nfs_server        = true,
  $mysql_server      = true,

  # Cloudstack installation flags
  $cloudstack_version     = $cloudstack::params::cloudstack_version,
  $cloudstack_setup_repos = true,

  # Management Server
  $cloudstack_install_mgmt      = true,
  $cloudstack_mgmt_package_name = $cloudstack::params::cloudstack_mgmt_package,
  $cloudstack_mgmt_service_name = $cloudstack::params::cloudstack_mgmt_service,

  # Usage Server
  $cloudstack_install_usage      = false,
  $cloudstack_usage_package_name = $cloudstack::params::cloudstack_usage_package,
  $cloudstack_usage_service_name = $cloudstack::params::cloudstack_usage_service,

  # XenServer Support: VHD-Util
  $vhd_util_url  = $cloudstack::params::vhd_util_url,
  $vhd_util_path = $cloudstack::params::vhd_util_path,

  # Cloudstack Installation Data
  $cloudstack_setup_dir             = $cloudstack::params::cloudstack_setup_dir,
  $cloudstack_installer_scripts_dir = $cloudstack::params::cloudstack_installer_scripts_dir,
  $cloudstack_setup_db_bin          = $cloudstack::params::cloudstack_setup_db_bin,
  $cloudstack_setup_mgmt_bin        = $cloudstack::params::cloudstack_setup_mgmt_bin,

  # CloudStack Deployment
  $cloudstack_master = true,

  $hostname_cloudstack = 'localhost',
  $hostname_database   = 'localhost',
  $hostname_nfs        = 'localhost',

  # Database
  $database_username     = 'cloudstack',
  $database_password     = undef,
  $database_server_key   = undef,
  $database_database_key = undef,

  # System Templates
  $hypervisor_support    = ['hyperv', 'xenserver', 'vmware', 'kvm', 'lxc'],
  $sys_tpl_installer_bin = $cloudstack::params::sys_tpl_installer_bin,
  $sys_tpl_url           = $cloudstack::params::sys_tpl_url,

  # MySQL Deployment
  $cloudstack_server_count = 1,
  $mysql_confd_dir         = $cloudstack::params::mysql_confd_dir,
  $mysql_service_name      = $cloudstack::params::mysql_service_name,

  # NFS Deployment
  $nfs_manage_dir     = $cloudstack::params::nfs_manage_dir,
  $nfs_root_dir       = $cloudstack::params::nfs_root_dir,
  $nfs_export_clients = $cloudstack::params::nfs_export_clients,
  $nfs_exports        = ['secondary'],
) inherits cloudstack::params {
  # Classes
  contain 'cloudstack::install'
  contain 'cloudstack::config'
  contain 'cloudstack::service'

  # Ordering
  Class['cloudstack::install'] -> Class['cloudstack::config'] -> Class['cloudstack::service']
}
