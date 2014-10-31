# Private Class: cloudstack::config
#
# Handes the configuration part.
# It is not recommended to use this class direct
# Use the "cloudstack" class instead or the individual config classes:
# * cloudstack::config::cloudstack
# * cloudstack::config::nfs
# * cloudstack::config::mysql
#
class cloudstack::config {
  anchor {'dependencies': }

  if ($::cloudstack::cloudstack_server) {
     Anchor['dependencies'] -> class { 'cloudstack::config::cloudstack': }
  }

  if ($::cloudstack::nfs_server) {
    class { 'cloudstack::config::nfs': } -> Anchor['dependencies']
  }

  if ($::cloudstack::mysql_server) {
    class { 'cloudstack::config::mysql': } -> Anchor['dependencies']
  }
}
