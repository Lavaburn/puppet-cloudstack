# Class: cloudstack::install::cloudstack
#
# Installs CloudStack Management Server package
#
# Parameters:
#  These flags can be turned off to integrate with other puppet modules.
#   * include_apt_class (boolean): Whether to include Apt class. Default = true
#
# When using the main "cloudstack" class, use Hiera Data Bindings
# to disable the compatibility flags.
#
#  Normal configuration (taken over from cloudstack class)
#   * install_source (string): See 'cloudstack' class
#   * install_version (string): See 'cloudstack' class
#   * hypervisor_support (array): See 'cloudstack' class
#   * major_version (string): Cloudstack Version (4.0 - 4.4)
#
class cloudstack::install::cloudstack (
  # Comptibility Flags
  $include_apt = true,

  # User Configuration
  $install_source     = $::cloudstack::cloudstack_install_source,
  $install_version    = $::cloudstack::cloudstack_install_version,
  $hypervisor_support = $::cloudstack::cloudstack_hypervisor_support,

  $major_version      = $::cloudstack::cloudstack_major_version,
) {
  # Validation
  validate_re($install_source, [ '^apache$' ])
  validate_string($install_version)
  validate_array($hypervisor_support)

  case $install_source {
    'apache': {
		  case $::osfamily {
		    'redhat': {
		     $repository = $::cloudstack::params::cloudstack_yum_repository[$major_version]

          file { '/etc/yum.repos.d/cloudstack.repo':
            content => template('cloudstack/cloudstack.repo.erb')
          }
          ->
          package { $::cloudstack::params::cloudstack_mgmt_package_name:
            ensure => $install_version,
          }
		    }
        'debian': {
          case $::operatingsystem {
            'Ubuntu': {
		          if ($include_apt) {
		            include apt
		          }

		          apt::source { 'cloudstack':
		            comment           => 'Official Apache repository for Cloudstack',
		            location          => $::cloudstack::params::cloudstack_apt_repository,
		            release           => $::cloudstack::params::cloudstack_apt_release,
		            repos             => $::cloudstack::cloudstack_major_version,
		            include_src       => false,
		            key               => '86C278E3',
		            key_server        => 'keyserver.ubuntu.com',
		          }
              ->
		          package { $::cloudstack::params::cloudstack_mgmt_package_name:
		            ensure => $install_version,
		          }

              # Documented bug, fixed in 4.3.1 and 4.4.x
		          if ($install_version =~ /^4.3.0/) {
		            package { 'libmysql-java':
		              ensure => 'installed',
 	              }
 	            }
	          }
	          default: {
				      fail('Debian support has not yet been implemented/tested.')
				    }
			    }
			  }
			  default: {
			    fail("Unsupported osfamily: ${::osfamily}")
			  }
  	  }
    }
    default: {
      fail('Only Apache apt repo is supported. Use install_source = "apache"')
    }
  }

  if ('xenserver' in $hypervisor_support) {
    include wget

    Package[$::cloudstack::params::cloudstack_mgmt_package_name]
    ->
		wget::fetch { 'http://download.cloud.com.s3.amazonaws.com/tools/vhd-util':
		  destination => "${cloudstack::params::vhd_util_path}/vhd-util",
		}
  }
}
