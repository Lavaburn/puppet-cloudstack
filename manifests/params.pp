# Private Class: cloudstack::params
#
# Contains system-specific parameters
#
# Parameters:
# - cloudstack_repository: Repository URL for CloudStack
# - cloudstack_package_name: Package to install CloudStack Management Server
# - cloudstack_apt_release: version of Ubuntu [trusty, precise]
#
class cloudstack::params {
  # TODO OS Specific ?
  $system_template_installer_bin = '/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt'

  # TODO version specific => ARRAY !!!
  $system_template_url = 'http://cloudstack.apt-get.eu/systemvm/4.4'
  $system_template_image_version = '4.4.1-7'

  case $::osfamily {
    'redhat': {
      $vhd_util_path = '/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver'

      fail('Redhat support has not yet been implemented.')
    }
    'debian': {
      $vhd_util_path = '/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver'

      case $::operatingsystem {
        'Ubuntu': {
		      $cloudstack_repository = 'http://cloudstack.apt-get.eu/ubuntu'
          $cloudstack_package_name = 'cloudstack-management'

		      case $::lsbdistcodename {
		        'precise','quantal','raring','saucy': {
		          $cloudstack_apt_release = 'precise'
		        }
		        'trusty','utopic','vivid': {
		          $cloudstack_apt_release = 'trusty'
		        }
		        default: {
		          fail("Unsupported version of Ubuntu: ${::lsbdistcodename}")
		        }
		      }
		    }
		    default: {
		      fail('Debian support has not yet been tested.')
		    }
      }
    }
		default: {
		  fail("Unsupported osfamily: ${::osfamily}")
		}
  }
}
