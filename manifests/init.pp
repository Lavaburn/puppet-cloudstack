# Class: cloudstack
#
# This module manages Apache CloudStack
# It can install the management server, mysql database and NFS server.
#
# Parameters:
#  Installation:
#    The following parameters are valid for these "modules":
#    'cloudstack', 'nfs', 'mysql'
#    * <module>_server (boolean): Whether to install/configure this part.
#      Default = true
#    * <module>_install (boolean): Whether to install this part. Default = true
#    * <module>_install_source (string): Source to install package from.
#      * Cloudstack: 'apache' (Apache-managed APT/YUM repo). Default: 'apache'
#      * NFS: 'puppet' (??? Puppet Module). Default: 'puppet'
#      * MySQL: 'puppet' (puppetlabs/mysql Puppet module). Default: 'puppet'
#    * <module>_install_version (string): Version to install. Default = 'latest'
#
#  Configuration:
#   * first_time_setup (boolean): Whether to initialise the MySQL Database.
#     (Only runs on cloudstack management server). Default = true
#   * create_system_templates (boolean): Whether to add system VM templates
#     to the secondary storage (NFS). (Also see cloudstack_hypervisor_support)
#     (Only runs on cloudstack management server). Default = true
#   * hostname_nfs (string): Hostname/IP of NFS server. Default = 'localhost'
#   * hostname_db (string): Hostname/IP of (Master) MySQL Server.
#     Default = 'localhost'
#   * cloudstack_hypervisor_support (array):
#       This array defines which templates to install on first install.
#       Default: ['hyper-v', 'xenserver', 'vsphere', 'kvm', 'lxc'],
#   * database_server_key (string): Key to protect properties file secrets.
#     (REQUIRED - Recommended through Hiera-eyaml)
#   * database_db_key (string): Key to protect database secrets.
#     (REQUIRED - Recommended through Hiera-eyaml)
#   * database_username (string): Username for MySQL Database.
#     Default = 'cloudstack'
#   * database_password (string): Password for MySQL Database.
#     (REQUIRED - Recommended through Hiera-eyaml)
#   * management_server_ip (string): IP address of the Management Server
#     (REQUIRED - Recommended through Hiera)
#   * mysql_class_override_options (hash): Overrides the MySQL default config.
#     Default: {}
#   * cloudstack_server_count (number): Number of Cloudstack servers
#     to be managed (MySQL setting)
#   * nfs_exports (array): This array lists all the NFS export targets
#     The targets will be sub-folders of /exports. Default = ['secondary']
#
# Requires: see Modulefile
#
class cloudstack (
  # Flags to set deployment scenario
  $cloudstack_server = true,
  $nfs_server        = true,
  $mysql_server      = true,

  # Installation flags
  $cloudstack_install = true,
  $nfs_install        = true,
  $mysql_install      = true,

  # Installation source flags
  $cloudstack_install_source = 'apache',
  $nfs_install_source        = 'puppet',
  $mysql_install_source      = 'puppet',

	# Versioning
	$cloudstack_install_version = 'latest',
  $nfs_install_version        = 'latest',
  $mysql_install_version      = 'latest',

  # CloudStack Deployment
  $first_time_setup               = true,
  $create_system_templates        = true,
  $hostname_nfs                   = 'localhost',
  $hostname_db                    = 'localhost',
  $cloudstack_hypervisor_support  = ['xenserver', 'kvm'], #TODO [TESTPHASE] REPLACE ['hyperv', 'xenserver', 'vmware', 'kvm', 'lxc'],
    # Required fields. Highly recommended to use hiera-eyaml or similar
    $database_server_key  = 'secret', # TODO [TESTPHASE] REMOVE !!!
    $database_db_key      = 'secret', # TODO [TESTPHASE] REMOVE !!!
  $database_username    = 'cloudstack',
    # Required fields. Highly recommended to use hiera-eyaml or similar
    $database_password   = 'kcatsduolc', # TODO [TESTPHASE] REMOVE !!!
  $management_server_ip  = '127.0.0.1', #TODO [TESTPHASE] REMOVE !!!

  # MySQL Deployment
  $mysql_class_override_options   = {},
  $cloudstack_server_count        = 1,

  # NFS Deployment
  $nfs_exports  = ['secondary'],
) {
  # Validation
  validate_bool($cloudstack_server, $nfs_server, $mysql_server)
  validate_bool($cloudstack_install, $nfs_install, $mysql_install)

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

  # Include and define dependencies
  class { 'cloudstack::install': } ->
  class { 'cloudstack::config': } ->
  Class['cloudstack']
}
