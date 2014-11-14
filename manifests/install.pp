# Class: cloudstack::install
#
# This is a private class. Only use the 'cloudstack' class.
#
# Handes the installation part.
#
class cloudstack::install inherits ::cloudstack {
  validate_bool($::cloudstack::cloudstack_server, $::cloudstack::nfs_server, $::cloudstack::mysql_server)
  validate_bool($::cloudstack::cloudstack_install)

  if ($::cloudstack::cloudstack_server and $::cloudstack::cloudstack_install) {
    contain 'cloudstack::install::cloudstack'
  }
}
