# Definition: cloudstack::config::nfs::export
#
# NFS folder export
#
# Parameters:
#   * [title] (string): The foldername to export
#   * root_dir (absolute path): Path of parent directory.
#
# Example:
# cloudstack::config::nfs::export { 'export1':
#   root_dir => '/exports',
# }
# => This will export /exports/export1
#
define cloudstack::config::nfs::export (
  $root_dir,
) {
  # Validation
  validate_absolute_path($root_dir)
  validate_string($title)

  $folder = "${root_dir}/${title}"

  File[$root_dir] ->
  file { $folder:
    ensure  => 'directory',
  }

  # TODO [FEATURE-REQUEST: Configure without Puppet echocat/nfs module ???]

  # No spaces !!!
  File[$folder] -> nfs::server::export { $folder:
    clients => '*(rw,async,no_root_squash,no_subtree_check)',
  }
}
