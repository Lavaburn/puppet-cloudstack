# Class: cloudstack::install::repo::apt
#
# This is a private class used by 'cloudstack::install::repo'
# The parameters can be changed using Hiera.
#
# Parameters:
# * repository_url (string): APT Repository URL
# * key (string): APT Key
# * keyserver (string): APT Keyserver
#
# Module Dependencies
#   * puppetlabs-apt >= 2.0.0
#
class cloudstack::install::repo::apt (
  $repository_url = $cloudstack::params::repository_url,
  $key            = $cloudstack::params::apt_key,
  $keyserver      = $cloudstack::params::apt_keyserver,
) inherits cloudstack::install::repo {
  # Parameters
  $version = $cloudstack::install::repo::version

  # Validation
  validate_string($repository_url, $key, $keyserver, $version)

  # Repository Setup
  case $::operatingsystem {
    'Ubuntu': {
      case $::lsbdistcodename {
        'precise','quantal','raring','saucy': {
          $release = 'precise'

          case $version {
            /^4.0.*/: {
              $major_version = '4.0'
            }
            /^4.1.*/: {
              $major_version = '4.1'
            }
            /^4.2.*/: {
              $major_version = '4.2'
            }
            /^4.3.*/: {
              $major_version = '4.3'
            }
            /^4.4.*/: {
              $major_version = '4.4'
            }
            /^4.5.*/: {
              $major_version = '4.5'
            }
            /^4.6.*/: {
              $major_version = '4.6'
            }
            /^4.7.*/: {
              $major_version = '4.7'
            }
            /^4.8.*/: {
              $major_version = '4.8'
            }
            'latest': {
              $major_version = '4.8'
            }
            default: {
              fail('precise currently only supports versions 4.0 - 4.8')
            }
          }
        }
        'trusty','utopic','vivid','wily': {
          $release = 'trusty'

          case $version {
            /^4.3.*/: {
              $major_version = '4.3'
            }
            /^4.4.*/: {
              $major_version = '4.4'
            }
            /^4.5.*/: {
              $major_version = '4.5'
            }
            /^4.6.*/: {
              $major_version = '4.6'
            }
            /^4.7.*/: {
              $major_version = '4.7'
            }
            /^4.8.*/: {
              $major_version = '4.8'
            }
            /^4.9.*/: {
              $major_version = '4.9'
            }
            'latest': {
              $major_version = '4.9'
            }
            default: {
              fail('trusty currently only supports versions 4.3 - 4.9')
            }
          }
        }
        default: {
          fail("Ubuntu Version ${::lsbdistcodename} is not supported at present. Only precise and trusty variants are supported.")
        }
      }

      include ::apt

      apt::source { 'cloudstack':
        comment  => 'Official Apache repository for Cloudstack',
        location => "${repository_url}/ubuntu",
        release  => $release,
        repos    => $major_version,
        key      => {
          'id'     => $key,
          'server' => $keyserver,
        }
      }
    }
    default: {
      fail("Operating System ${::operatingsystem} is not supported at present. Only Ubuntu is supported.")
    }
  }
}
