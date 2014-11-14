# Class: cloudstack::config::nfs
#
# This is a private class. Only use the 'cloudstack' class.
#
# Configures NFS server
#
class cloudstack::config::nfs inherits ::cloudstack {
  # Validation
  validate_bool($::cloudstack::nfs_manage_dir)
  validate_absolute_path($::cloudstack::nfs_root_dir)
  validate_array($::cloudstack::nfs_exports)

  # Manage root dir
  if ($::cloudstack::nfs_manage_dir) {
    file { $::cloudstack::nfs_root_dir:
      ensure  => 'directory',
    }
  }

  cloudstack::config::nfs::export { $::cloudstack::nfs_exports:
    root_dir  => $::cloudstack::nfs_root_dir,
  }
}
