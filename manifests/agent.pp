# Class: cloudstack::agent
#
# This module installs Apache CloudStack Agent
# (to be run on Hypervisor)
#
# Parameters:
#  TODO AGENT - PARAMS
#
class cloudstack::agent (
  # Installation source flags
  $install_source = 'apache',

	# Versioning
	$install_version = 'latest',
) {
  # TODO [COMPATIBILITY: Test on XenServer/Redhat/Debian/...]
  # TODO AGENT - PACKAGE INSTALL => cloudstack-agent

  include cloudstack::params

  # Validation
  validate_re($install_source, [ '^apache$' ])
  validate_string($install_version)

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
          $repository = $cloudstack::params::cloudstack_repository

          file { '/etc/yum.repos.d/cloudstack.repo':
            content => template('cloudstack/cloudstack.repo.erb')
          }
          ->
          package { $cloudstack::params::cloudstack_agent_package_name:
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
                location          => $cloudstack::params::cloudstack_repository,
                release           => $cloudstack::params::cloudstack_apt_release,
                repos             => $real_repo_version,
                include_src       => false,
                key               => 'B7C7765A',
                key_source        => 'http://cloudstack.apt-get.eu/release.asc',
              }
              ->
              package { $cloudstack::params::cloudstack_agent_package_name:
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
}
