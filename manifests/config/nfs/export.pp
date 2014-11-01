# Class: cloudstack::config::nfs::export
#
#
#
# Parameters:
#   * root_dir (string): Path of parent directory. Default = /exports
#
class cloudstack::config::nfs::export (
  # User Configuration
  $root_dir = '/exports',
) {
  # Validation
  validate_string($root_dir)

  $folder = "${root_dir}/${title}"

  file { $folder:
    ensure  => 'directory',
  } -> File[$root_dir]

  nfs::server::export{ $folder:
    #clients => '* (rw,insecure,async,no_root_squash) localhost(rw)',
    clients => '* (rw,async,no_root_squash,no_subtree_check)',
  }
}
