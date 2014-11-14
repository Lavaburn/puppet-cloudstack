# Class: cloudstack::install::cloudstack
#
# This is a private class. Only use the 'cloudstack' class.
#
# Installs CloudStack Management Server package
#
class cloudstack::install::cloudstack inherits ::cloudstack {
  # Validation
  validate_string($::cloudstack::real_cloudstack_yum_repository, $::cloudstack::real_cloudstack_apt_repository)
  validate_string($::cloudstack::cloudstack_mgmt_package_name, $::cloudstack::cloudstack_install_version)
  validate_string($::cloudstack::cloudstack_apt_release, $::cloudstack::cloudstack_major_version)
  validate_string($::cloudstack::cloudstack_apt_key, $::cloudstack::cloudstack_apt_keyserver)
  validate_array($::cloudstack::hypervisor_support)

  case $::osfamily {
    'redhat': {
      $repository = $::cloudstack::real_cloudstack_yum_repository

      file { '/etc/yum.repos.d/cloudstack.repo':
        content => template('cloudstack/cloudstack.repo.erb')
      }
      ->
      package { $::cloudstack::cloudstack_mgmt_package_name:
        ensure => $::cloudstack::cloudstack_install_version,
      }
    }
    'debian': {
      apt::source { 'cloudstack':
        comment           => 'Official Apache repository for Cloudstack',
        location          => $::cloudstack::real_cloudstack_apt_repository,
        release           => $::cloudstack::cloudstack_apt_release,
        repos             => $::cloudstack::cloudstack_major_version,
        include_src       => false,
        key               => $::cloudstack::cloudstack_apt_key,
        key_server        => $::cloudstack::cloudstack_apt_keyserver,
      }
      ->
      package { $::cloudstack::cloudstack_mgmt_package_name:
        ensure => $::cloudstack::cloudstack_install_version,
      }

      # Documented bug, fixed in 4.3.1 and 4.4.x
      if ($::cloudstack::cloudstack_install_version =~ /^4.3.0/) {
        package { 'libmysql-java':
          ensure => 'installed',
        }
      }
	  }
	  default: {
	    fail("Unsupported osfamily: ${::osfamily}")
	  }
  }

  if ('xenserver' in $::cloudstack::hypervisor_support) {
    Package[$::cloudstack::cloudstack_mgmt_package_name]
    ->
		wget::fetch { $::cloudstack::vhd_util_url:
		  destination => "${::cloudstack::vhd_util_path}/vhd-util",
		}
  }
}
