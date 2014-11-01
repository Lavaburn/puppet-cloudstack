# Class: cloudstack::install::nfs
#
# Installs NFS package
#
# Parameters:
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

  if ($install_version != 'latest') {
     fail('Version selection is not yet supported. Use install_version = "latest"')
  }

  case $install_source {
    'puppet': {
      include nfs::server
    }
    default: {
      fail('Only Puppet Module haraldsk/nfs is supported. Use install_source = "puppet"')
    }
  }
}
