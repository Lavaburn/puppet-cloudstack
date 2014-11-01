# Class: cloudstack::config::nfs
#
# Configures NFS server
#
# Parameters:
#  Normal configuration (taken over from cloudstack class)
#   * nfs_exports (array): See 'cloudstack' class
#
class cloudstack::config::nfs (
  $nfs_exports              = $::cloudstack::nfs_exports,
) {
  # Validation
  validate_array($nfs_exports)

  $root_dir = '/exports'

  file { $root_dir:
    ensure  => 'directory',
  }

  cloudstack::config::nfs::export { $nfs_exports:
    root_dir  => $root_dir,
  }
}
