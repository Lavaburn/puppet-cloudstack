# Definition: cloudstack::config::nfs::export
#
#
#
# Parameters:
#   * root_dir (string): Path of parent directory. Default = /exports
#
define cloudstack::config::nfs::export (
  # User Configuration
  $root_dir = '/exports',
) {
  # Validation
  validate_string($root_dir)

  $folder = "${root_dir}/${title}"

  File[$root_dir] ->
  file { $folder:
    ensure  => 'directory',
  }

  # No spaces !!!
  nfs::server::export { $folder:
    clients => ['*(rw,async,no_root_squash,no_subtree_check)'],
  }
}
