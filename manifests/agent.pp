# Class: cloudstack::agent
#
# This module installs Apache CloudStack Agent
# (required by KVM Hypervisor)
#
# Parameters:
#   * version (string): Version of the agent package (Default: latest)
#   * package_name (string): Agent package name (Default: cloudstack-agent)
#   * yum_repository (string): YUM Repository URL
#   * apt_repository (string): APT Repository URL
#   * apt_release (string): APT Release name
#   * apt_key (string): APT Key
#   * apt_keyserver (string): APT Keyserver
#
class cloudstack::agent (
  $version        = 'latest',
  $package_name   = 'cloudstack-agent',

  $yum_repository = undef,

  $apt_repository = undef,
  $apt_release    = $cloudstack::params::cloudstack_apt_release,
  $apt_key        = '86C278E3',
  $apt_keyserver  = 'keyserver.ubuntu.com',
) inherits cloudstack::params {
  # Validation
  validate_string($version, $package_name)

  # Cloudstack Version
  case $version {
    'latest': {
      $cloudstack_major_version = '4.4'
    }
    /^4.0.*/: {
      $cloudstack_major_version = '4.0'
    }
    /^4.1.*/: {
      $cloudstack_major_version = '4.1'
    }
    /^4.2.*/: {
      $cloudstack_major_version = '4.2'
    }
    /^4.3.*/: {
      $cloudstack_major_version = '4.3'
    }
    /^4.4.*/: {
      $cloudstack_major_version = '4.4'
    }
    default: {
      fail('Currently only supports versions 4.0.x - 4.4.x')
    }
  }

  if $yum_repository != undef {
    validate_string($yum_repository)

    $real_cloudstack_yum_repository = $yum_repository
  } else {
    $real_cloudstack_yum_repository = $cloudstack::params::cloudstack_yum_repository_hash[$cloudstack_major_version]
  }

  if $apt_repository != undef {
    validate_string($apt_repository)

    $real_cloudstack_apt_repository = $apt_repository
  } else {
    $real_cloudstack_apt_repository = $cloudstack::params::cloudstack_apt_repository
  }

  case $::osfamily {
    'RedHat': {
      $repository = $real_cloudstack_yum_repository

      file { '/etc/yum.repos.d/cloudstack.repo':
        content => template('cloudstack/cloudstack.repo.erb')
      }
      ->
      package { $package_name:
        ensure => $version,
      }
    }
    'Debian': {
      case $::operatingsystem {
        'Ubuntu': {
          include apt

          apt::source { 'cloudstack':
            comment     => 'Official Apache repository for Cloudstack',
            location    => $real_cloudstack_apt_repository,
            release     => $apt_release,
            repos       => $cloudstack_major_version,
            include_src => false,
            key         => $apt_key,
            key_server  => $apt_keyserver,
          }
          ->
          package { $package_name:
            ensure => $version,
          }
        }
        default: {
          fail('Non-Ubuntu Debian support has not yet been implemented/tested.')
        }
      }
    }
    default: {
      fail("Unsupported OS Family: ${::osfamily}")
    }
  }
}
