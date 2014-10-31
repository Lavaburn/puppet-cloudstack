# Class: cloudstack::install::nfs
#
# Installs NFS package
#
# Parameters:
#  These flags can be turned off to integrate with other puppet modules.
#   TODO No Flags?
#
# When using the main "cloudstack" class, use Hiera Data Bindings
# to disable the compatibility flags.
#
#  Normal configuration (taken over from cloudstack class)
#   * install_source (string): See 'cloudstack' class
#   * install_version (string): See 'cloudstack' class
#
class cloudstack::install::nfs (
  # User Configuration
  $install_source     = $::cloudstack::nfs_install_source,      # 'puppet',
  $install_version    = $::cloudstack::nfs_install_version,     # 'latest',
) {
  # Validation
  validate_re($install_source, [ '^puppet$' ])
  validate_string($install_version)

  # TODO Install package for NFS SERVER
    # sudo yum install nfs-utils

}
