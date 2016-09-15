# Class: cloudstack::service
#
# This is a private class used by the 'cloudstack' class.
#
# This class manages the Cloudstack services
#
class cloudstack::service (
  $enable_server = $cloudstack::cloudstack_server,

  $install_mgmt  = $cloudstack::cloudstack_install_mgmt,
  $install_usage = $cloudstack::cloudstack_install_usage,

  $mgmt_service_name  = $cloudstack::cloudstack_mgmt_service_name,
  $usage_service_name = $cloudstack::cloudstack_usage_service_name,
) inherits ::cloudstack {
  # Validation
  validate_bool($enable_server, $install_mgmt, $install_usage)
  validate_string($mgmt_service_name, $usage_service_name)

  # Management Service
  if ($enable_server) {
    if ($install_mgmt) {
      service { $mgmt_service_name:
        ensure => 'running',
      }
    }

    # Usage Server Service
    if ($install_usage) {
      service { $usage_service_name:
        ensure => 'running',
      }
    }
  }
}
