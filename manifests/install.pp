# Class: cloudstack::install
#
# This is a private class used by the 'cloudstack' class.
#
# This class sets up the Cloudstack repositories and installs the packages
#
class cloudstack::install (
  $cloudstack_server  = $cloudstack::cloudstack_server,
) inherits ::cloudstack {
  # Validation
  validate_bool($cloudstack_server)

  # Cloudstack installation
  if ($cloudstack_server) {
    contain 'cloudstack::install::cloudstack'
  }

  # This module does not install MySQL and NFS Server !
}
