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
#
class cloudstack::install::cloudstack (
  # Comptibility Flags
  $include_apt = true,

  # User Configuration
  $install_source     = $::cloudstack::cloudstack_install_source,
  $install_version    = $::cloudstack::cloudstack_install_version,
  $hypervisor_support = $::cloudstack::cloudstack_hypervisor_support,
) {
  include cloudstack::params

  # Validation
  validate_re($install_source, [ '^apache$' ])
  validate_string($install_version)
  validate_array($hypervisor_support)

  # TODO EXTRACT CODE FOR USE IN AGENT !!!

  case $install_source {
    'apache': {
      case $install_version {
        'latest': {
          $real_repo_version = '4.4'
        }
        '/^4.0/': {
          $real_repo_version = '4.0'
        }
        '/^4.1/': {
          $real_repo_version = '4.1'
        }
        '/^4.2/': {
          $real_repo_version = '4.2'
        }
        '/^4.3/': {
          $real_repo_version = '4.3'
        }
        '/^4.4/': {
          $real_repo_version = '4.4'
        }
        default: {
          fail('Apache apt repository only supports versions 4.0.x - 4.4.x')
        }
      }

		  case $::osfamily {
		    'redhat': {
		      fail('Redhat support has not yet been implemented/tested.')

		      # /etc/yum.repos.d/cloudstack.repo
		      #   [cloudstack]
		      #   name=cloudstack
		      #   baseurl=http://cloudstack.apt-get.eu/rhel/4.4/
		      #   enabled=1
		      #   gpgcheck=0
		    }
        'debian': {
          case $::operatingsystem {
            'Ubuntu': {
		          if ($include_apt) {
		            include apt
		          }

# TODO Was idempotency broken? This keeps repeating...
# Notice: /Stage[main]/Cloudstack::Install::Cloudstack/Apt::Source[cloudstack]/
# Apt::Key[Add key: B7C7765A from Apt::Source cloudstack]/
# Apt_key[Add key: B7C7765A from Apt::Source cloudstack]/ensure: created

		          apt::source { 'cloudstack':
		            comment           => 'Official Apache repository for Cloudstack',
		            location          => $cloudstack::params::cloudstack_repository,
		            release           => $cloudstack::params::cloudstack_apt_release,
		            repos             => $real_repo_version,
		            include_src       => false,
		            key               => 'B7C7765A',
		            key_source        => 'http://cloudstack.apt-get.eu/release.asc',
		          }
              ->
		          package { $cloudstack::params::cloudstack_package_name:
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

    Package[$cloudstack::params::cloudstack_package_name]
    ->
		wget::fetch { 'http://download.cloud.com.s3.amazonaws.com/tools/vhd-util':
		  destination => "${cloudstack::params::vhd_util_path}/vhd-util",
		}
  }
}
