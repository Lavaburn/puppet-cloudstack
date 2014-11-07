# Class: cloudstack::agent
#
# This module installs Apache CloudStack Agent
# (required by KVM Hypervisor)
#
# Parameters:
#  Installation:
#    * install_source (string): Source to install package from.
#      Default: 'apache' (Apache-managed APT/YUM repo)
#    * install_version (string): Version to install. Default = 'latest'
#
class cloudstack::agent (
  # Installation source flags
  $install_source = 'apache',

	# Versioning
	$install_version = 'latest',
) {
  # TODO [COMPATIBILITY: Test on XenServer/Redhat/Debian/...]

  # Validation
  validate_re($install_source, [ '^apache$' ])
  validate_string($install_version)

  # Cloudstack Version
  case $install_version {
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

  case $install_source {
    'apache': {
      case $::osfamily {
        'redhat': {
          $repository = $::cloudstack::params::cloudstack_yum_repository[$cloudstack_major_version]

          file { '/etc/yum.repos.d/cloudstack.repo':
            content => template('cloudstack/cloudstack.repo.erb')
          }
          ->
          package { $::cloudstack::params::cloudstack_agent_package_name:
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
                key               => 'B7C7765A',
                key_source        => 'http://cloudstack.apt-get.eu/release.asc',
              }
              ->
              package { $::cloudstack::params::cloudstack_agent_package_name:
                ensure => $install_version,
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

  # TODO - EDIT /etc/libvirt/libvirtd.conf
  #  listen_tls = 0
  #  listen_tcp = 1
  #  tcp_port = "16059"
  #  auth_tcp = "none"
  #  mdns_adv = 0

  # TODO - CENTOS - /etc/sysconfig/libvirtd
  # LIBVIRTD_ARGS="--listen"
  # => service libvirtd restart

  # TODO - UBUNTU - /etc/default/libvirt-bin
  # libvirtd_opts="-d -l"
  # => service libvirt-bin restart



}
