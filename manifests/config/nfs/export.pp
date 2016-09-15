# Definition: cloudstack::config::nfs::export
#
# NFS folder export
#
# Parameters:
#   * [title] (string): The foldername to export
#   * root_dir (absolute path): Path of parent directory.
#   * clients (string): Clients and options to allow export for
#
# Example:
# cloudstack::config::nfs::export { 'export1':
#   root_dir => '/exports',
# }
# => This will export /exports/export1
#
define cloudstack::config::nfs::export (
  $root_dir,
  $clients = '*(rw,async,no_root_squash,no_subtree_check)',
) {
  # Validation
  validate_absolute_path($root_dir)
  validate_string($clients)

  $folder = "${root_dir}/${title}"

  # Create Folder
  file { $folder:
    ensure  => 'directory',
  }

  # Export
  File[$folder]
  ->
  nfs::server::export { $folder:
    clients => $clients,
  }
}
