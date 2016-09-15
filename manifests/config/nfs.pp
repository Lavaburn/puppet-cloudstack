# Class: cloudstack::config::nfs
#
# This is a private class used by the 'cloudstack::config' class.
#
# Configures NFS server
#
class cloudstack::config::nfs (
  $manage_dir     = $cloudstack::nfs_manage_dir,
  $root_dir       = $cloudstack::nfs_root_dir,
  $export_clients = $cloudstack::nfs_export_clients,
  $exports        = $cloudstack::nfs_exports,
) inherits cloudstack::config {
  # Validation
  validate_bool($manage_dir)
  validate_absolute_path($root_dir)
  validate_string($export_clients)
  validate_array($exports)

  # Manage root dir
  if ($manage_dir) {
    file { $root_dir:
      ensure  => 'directory',
    }
  }

  # Create NFS Exports
  cloudstack::config::nfs::export { $exports:
    root_dir => $root_dir,
    clients  => $export_clients,
  }
}
