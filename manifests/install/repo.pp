# Class: cloudstack::install::repo
#
# This is a private class used by 'cloudstack' and 'cloudstack::agent'
# Sets up repository for CloudStack
#
# Parameters:
#   * version (string): The full version of the package to be installed.
#
class cloudstack::install::repo (
  $version,
) inherits cloudstack::params {
  # Validation
  validate_string($version)

  # Setup Repo
  case $::osfamily {
    'RedHat': {
      include cloudstack::install::repo::yum
    }
    'Debian': {
      include cloudstack::install::repo::apt
    }
    default: {
      fail("Unsupported OS Family: ${::osfamily}")
    }
  }
}
