# Class: cloudstack::install::repo::yum
#
# This is a private class used by 'cloudstack::install::repo'
# The parameters can be changed using Hiera.
#
# Parameters:
# * repository_url (string): YUM Repository URL
#
class cloudstack::install::repo::yum (
  $repository_url = $cloudstack::params::repository_url,
  $gpgkey         = $cloudstack::params::yum_gpgkey,
) inherits cloudstack::install::repo {
  # Parameters
  $version = $cloudstack::install::repo::version

  # Validation
  validate_string($repository_url, $gpgkey, $version)

  # Repository Setup
  case $::operatingsystem {
    'RedHat': {
      fail('This module currently does not support RHEL. Apache Cloudstack however contains repos for RHEL.')
    }
    'CentOS': {
      case $::operatingsystemmajrelease {
        '6': {
          case $version {
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
            /^4.9.*/: {
              $major_version = '4.9'
            }
            'latest': {
              $major_version = '4.9'
            }
            default: {
              fail('CentOS 6.x currently only supports versions 4.2 - 4.9')
            }
          }
        }
        '7': {
          case $version {
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
              fail('CentOS 7.x currently only supports versions 4.5 - 4.8')
            }
          }
        }
        default: {
          fail("CentOS Version ${::operatingsystemmajrelease} is not supported at present. Only 6 and 7 are supported.")
        }
      }

      $yumrepo_url = "${repository_url}/centos/${::operatingsystemmajrelease}/${major_version}"

      if ($gpgkey == 'absent') {
        $gpgcheck = false
      } else {
        $gpgcheck = true
      }

      yumrepo { 'cloudstack':
        name     => 'Official Apache repository for Cloudstack',
        baseurl  => $yumrepo_url,
        enabled  => true,
        gpgcheck => $gpgcheck,
        gpgkey   => $gpgkey,
      }
    }
    default: {
      fail("Operating System ${::operatingsystem} is not supported at present. Only CentOS is supported.")
    }
  }
}
