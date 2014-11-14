# Class: cloudstack::config
#
# This is a private class. Only use the 'cloudstack' class.
#
# Handes the configuration part.
#
class cloudstack::config inherits ::cloudstack {
  validate_bool($::cloudstack::cloudstack_server, $::cloudstack::nfs_server, $::cloudstack::mysql_server)

  anchor { 'cloudstack-config-dependencies': }

  if ($::cloudstack::nfs_server) {
    contain 'cloudstack::config::nfs'

    Class['cloudstack::config::nfs'] -> Anchor['cloudstack-config-dependencies']
  }

  if ($::cloudstack::mysql_server) {
    contain 'cloudstack::config::mysql'

    Class['cloudstack::config::mysql'] -> Anchor['cloudstack-config-dependencies']
  }

  if ($::cloudstack::cloudstack_server) {
    contain 'cloudstack::config::cloudstack'

    Anchor['cloudstack-config-dependencies']-> Class['cloudstack::config::cloudstack']
  }
}
