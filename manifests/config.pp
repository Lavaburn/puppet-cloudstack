# Class: cloudstack::config
#
# This is a private class used by the 'cloudstack' class.
#
# This class configures MySQL, NFS and Cloudstack
#
class cloudstack::config (
  $cloudstack_server = $cloudstack::cloudstack_server,
  $nfs_server        = $cloudstack::nfs_server,
  $mysql_server      = $cloudstack::mysql_server,
) inherits ::cloudstack {
  # Validation
  validate_bool($cloudstack_server, $nfs_server, $mysql_server)

  # NFS Server
  if ($nfs_server) {
    contain 'cloudstack::config::nfs'

    Class['cloudstack::config::nfs'] -> Anchor['cloudstack-config-dependencies']
  }

  # MySQL Server
  if ($mysql_server) {
    contain 'cloudstack::config::mysql'

    Class['cloudstack::config::mysql'] -> Anchor['cloudstack-config-dependencies']
  }

  # Cloudstack Server
  if ($cloudstack_server) {
    contain 'cloudstack::config::cloudstack'

    Anchor['cloudstack-config-dependencies']-> Class['cloudstack::config::cloudstack']
  }

  # Ordering
  anchor { 'cloudstack-config-dependencies': }
}
