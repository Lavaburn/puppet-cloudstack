# Private Class: cloudstack::install
#
# Handes the installation part.
# It is not recommended to use this class direct
# Use the "cloudstack" class instead or the individual install classes:
# * cloudstack::install::cloudstack
# * cloudstack::install::nfs
# * cloudstack::install::mysql
#
class cloudstack::install {
  if ($::cloudstack::cloudstack_server and $::cloudstack::cloudstack_install) {
    class { 'cloudstack::install::cloudstack': }
  }

  if ($::cloudstack::nfs_server and $::cloudstack::nfs_install) {
    class { 'cloudstack::install::nfs': }
  }

  if ($::cloudstack::mysql_server and $::cloudstack::mysql_install) {
    class { 'cloudstack::install::mysql': }
  }
}
