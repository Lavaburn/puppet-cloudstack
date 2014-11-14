# Class: cloudstack::params
#
# Contains system-specific parameters
#
# Parameters:
#   * cloudstack_mgmt_package_name (string): The name of the package to install for Cloudstack Management Server
#   * cloudstack_yum_repository_hash (hash): The YUM repository URL per major_version (4.0 - 4.4)
#   * cloudstack_apt_repository (string): The APT repository URL
#   * cloudstack_apt_release (string): Release from the APT repo. (Precise, Trusty)
#   * vhd_util_url (string): [XenServer support] URL to download vhd-util from
#   * vhd_util_path (string): [XenServer support] Path to copy vhd-util to
#   * create_sys_tpl_path (string): Path for new script to install system templates.
#   * nfs_secondary_storage_mount_dir (string): Directory to Mount Secondary Storage to for installation of system templates.
#   * system_template_image_version (string): Image version of the System Template
#   * system_template_installer_bin (string): Path to cloud-install-sys-tmplt
#   * system_template_url (string): URL where System Templates are downloaded from
#   * mysql_confd_dir (string): Path to MySQL conf.d directory
#   * mysql_service_name (string): Service name of MySQL
#
class cloudstack::params {
  $cloudstack_mgmt_package_name = 'cloudstack-management'

  $cloudstack_yum_repository_hash = {
    '4.0' => 'http://cloudstack.apt-get.eu/rhel/4.0/',
    '4.1' => 'http://cloudstack.apt-get.eu/rhel/4.1/',
    '4.2' => 'http://cloudstack.apt-get.eu/rhel/4.2/',
    '4.3' => 'http://cloudstack.apt-get.eu/rhel/4.3/',
    '4.4' => 'http://cloudstack.apt-get.eu/rhel/4.4/',
  }

  $cloudstack_apt_repository = 'http://cloudstack.apt-get.eu/ubuntu'

  case $::lsbdistcodename {
    'precise','quantal','raring','saucy': {
      $cloudstack_apt_release = 'precise'
    }
    'trusty','utopic','vivid': {
      $cloudstack_apt_release = 'trusty'
    }
    default: {
      warning("Unsupported version of Ubuntu: ${::lsbdistcodename}")
    }
  }

  $vhd_util_url   = 'http://download.cloud.com.s3.amazonaws.com/tools/vhd-util'
  $vhd_util_path  = '/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver'

  # Custom script, needs to be created in existing folder
  $create_sys_tpl_path = '/usr/share/cloudstack-common/scripts/installer/create-sys-tpl.sh'
  $nfs_secondary_storage_mount_dir = '/mnt/secondary'

  $system_template_image_version = '4.4.1-7'
  $system_template_installer_bin = '/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt'
  $system_template_url = 'http://cloudstack.apt-get.eu/systemvm/4.4'

  if defined(Class['::mysql::server']) {
    $mysql_service_name = 'mysqld'

    #TODO - Check why this return empty - $mysql_confd_dir = $::mysql::server::includedir

    case $::osfamily {
      'redhat': {
        $mysql_confd_dir = '/etc/my.cnf.d'
      }
      'debian': {
        $mysql_confd_dir = '/etc/mysql/conf.d'
      }
      default: {
        warning("Unsupported osfamily: ${::osfamily}")
      }
    }
  } else {
    case $::osfamily {
      'redhat': {
        case $::operatingsystem {
          'Fedora': {
            if is_integer($::operatingsystemrelease) and $::operatingsystemrelease >= 19 or $::operatingsystemrelease == 'Rawhide' {
              $provider = 'mariadb'
            } else {
              $provider = 'mysql'
            }
          }
          /^(RedHat|CentOS|Scientific|OracleLinux)$/: {
            if $::operatingsystemmajrelease >= 7 {
              $provider = 'mariadb'
            } else {
              $provider = 'mysql'
            }
          }
          default: {
            $provider = 'mysql'
          }
        }

        if $provider == 'mariadb' {
          $mysql_service_name = 'mariadb'
        } else {
          $mysql_service_name = 'mysqld'
        }
        $mysql_confd_dir = '/etc/my.cnf.d'
      }
      'debian': {
        $mysql_service_name = 'mysql'
        $mysql_confd_dir = '/etc/mysql/conf.d'

        case $::operatingsystem {
          'Ubuntu': {

          }
          default: {
            warning("Unsupported operatingsystem: ${::operatingsystem}")
          }
        }
      }
      default: {
        # Styling requires a default case - warning already set earlier
      }
    }
  }

  # $cloudstack_agent_package_name = 'cloudstack-agent'
}
