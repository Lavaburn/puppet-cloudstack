# Class: cloudstack::params
#
# Contains system-specific parameters
#
# Parameters:
#   * cloudstack_agent_version (string): The package version to install of Cloudstack Agent
#   * cloudstack_agent_package (string): The name of the package to install for Cloudstack Agent
#   * cloudstack_agent_setup_repo (boolean): Whether to setup Cloudstack Repositories for Cloudstack Agent
#   * cloudmonkey_version (string): The package version to install of CloudMonkey
#   * cloudmonkey_package_name (string): The name of the package to install for CloudMonkey
#   * cloudmonkey_setup_python (boolean): Whether to setup Python for CloudMonkey
#   * repository_url (string): The APT/YUM repository base URL
#   * apt_key (string): The APT key (Full GPG fingerprint)
#   * apt_keyserver (string): The keyserver where the APT key can be downloaded
#   * yum_gpgkey (string): URL where the YUM GPG key can be downloaded
#   * cloudstack_version (string): The package version of Cloudstack Management/Usage Server
#   * cloudstack_mgmt_package (string): The name of the package to install for Cloudstack Management Server
#   * cloudstack_usage_package (string): The name of the package to install for Cloudstack Usage Server
#   * cloudstack_setup_dir (absolute path): Path to the directory where setup information is stored
#   * cloudstack_installer_scripts_dir (absolute path): Path to the directory where installer scripts are stored
#   * cloudstack_setup_db_bin (absolute path): Path to the cloudstack-setup-databases binary
#   * cloudstack_setup_mgmt_bin (absolute path): Path to the cloudstack-setup-management binary
#   * cloudstack_mgmt_service (string): The name of the service to manage for Cloudstack Management Server
#   * cloudstack_usage_service (string): The name of the service to manage for Cloudstack Usage Server
#   * vhd_util_url (string): [XenServer support] URL to download vhd-util from
#   * vhd_util_path (absolute path): [XenServer support] Path to copy vhd-util to
#   * sys_tpl_installer_bin (absolute path): Path to the cloud-install-sys-tmplt binary
#   * sys_tpl_url (string): Base URL where System Templates are downloaded from
#   * mysql_confd_dir (absolute path): Path to MySQL conf.d directory. Set false if conf.d is not supported.
#   * mysql_service_name (string): Service name of MySQL. Set false if MySQL service is not managed by Puppet.
#   * nfs_manage_dir (boolean): Whether to manage the root directory used for NFS
#   * nfs_root_dir (absolute path): Path to the root directory where NFS data is stored
#   * nfs_export_clients (string): Access Levels (client+options) for the NFS exports.
#
class cloudstack::params {
  # Cloudstack Agent
  $cloudstack_agent_version    = 'latest'
  $cloudstack_agent_package    = 'cloudstack-agent'
  $cloudstack_agent_setup_repo = true

  # CloudMonkey
  $cloudmonkey_version      = 'present'
  $cloudmonkey_package_name = 'cloudmonkey'
  $cloudmonkey_setup_python = false

  # APT/YUM Repository
  $repository_url = 'http://cloudstack.apt-get.eu'
  $apt_key        = '567570BEE431B358135EB55CBBFCFE5386C278E3'
  $apt_keyserver  = 'keyserver.ubuntu.com'
  $yum_gpgkey     = 'http://cloudstack.apt-get.eu/RPM-GPG-KEY'

  # Server Packages
  $cloudstack_version       = 'latest'
  $cloudstack_mgmt_package  = 'cloudstack-management'
  $cloudstack_usage_package = 'cloudstack-usage'

  # Cloudstack Installation Data
  $cloudstack_setup_dir             = '/usr/share/cloudstack-management/setup'
  $cloudstack_installer_scripts_dir = '/usr/share/cloudstack-common/scripts/installer'
  $cloudstack_setup_db_bin          = '/usr/bin/cloudstack-setup-databases'
  $cloudstack_setup_mgmt_bin        = '/usr/bin/cloudstack-setup-management'

  # Services
  $cloudstack_mgmt_service  = 'cloudstack-management'
  $cloudstack_usage_service = 'cloudstack-usage'

  # XenServer Support: VHD-Util
  $vhd_util_url   = 'http://download.cloud.com.s3.amazonaws.com/tools/vhd-util'
  $vhd_util_path  = '/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver'

  # SystemVM Templates
  $sys_tpl_installer_bin = '/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt'
  $sys_tpl_url           = 'http://cloudstack.apt-get.eu/systemvm/'

  # MySQL Server
  $mysql_service_name = 'mysqld'

  case $::osfamily {
    'redhat': {
      $mysql_confd_dir = '/etc/my.cnf.d'
    }
    'debian': {
      $mysql_confd_dir = '/etc/mysql/conf.d'
    }
    default: {
      $mysql_confd_dir = false
    }
  }

  # NFS Server
  $nfs_manage_dir     = true
  $nfs_root_dir       = '/exports'
  $nfs_export_clients = '*(rw,async,no_root_squash,no_subtree_check)'
}
