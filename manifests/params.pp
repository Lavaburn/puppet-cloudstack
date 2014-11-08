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
  $system_template_url = {
    '4.0' => 'http://cloudstack.apt-get.eu/systemvm/4.4',
	  '4.1' => 'http://cloudstack.apt-get.eu/systemvm/4.4',
	  '4.2' => 'http://cloudstack.apt-get.eu/systemvm/4.4',
	  '4.3' => 'http://cloudstack.apt-get.eu/systemvm/4.4',
	  '4.4' => 'http://cloudstack.apt-get.eu/systemvm/4.4',
  }

  $system_template_image_version = {
    '4.0' => '4.4.1-7',
		'4.1' => '4.4.1-7',
		'4.2' => '4.4.1-7',
		'4.3' => '4.4.1-7',
		'4.4' => '4.4.1-7',
	}

  $cloudstack_mgmt_package_name = 'cloudstack-management'
  $cloudstack_agent_package_name = 'cloudstack-agent'

  case $::osfamily {
    'redhat': {
      $vhd_util_path = '/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver'
      $system_template_installer_bin = '/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt'

      $cloudstack_yum_repository = {
        '4.0' => 'http://cloudstack.apt-get.eu/rhel/4.0/',
			  '4.1' => 'http://cloudstack.apt-get.eu/rhel/4.1/',
			  '4.2' => 'http://cloudstack.apt-get.eu/rhel/4.2/',
			  '4.3' => 'http://cloudstack.apt-get.eu/rhel/4.3/',
			  '4.4' => 'http://cloudstack.apt-get.eu/rhel/4.4/',
		  }
    }
    'debian': {
      $vhd_util_path = '/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver'
      $system_template_installer_bin = '/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt'

      case $::operatingsystem {
        'Ubuntu': {
		      $cloudstack_apt_repository = 'http://cloudstack.apt-get.eu/ubuntu'

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
