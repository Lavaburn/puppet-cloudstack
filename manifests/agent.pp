# Class: cloudstack::agent
#
# This class installs Apache CloudStack Agent (required by KVM Hypervisor)
#
# Parameters:
#   * version (string): Version of the agent package (Default: latest)
#   * package_name (string): Agent package name (Default: cloudstack-agent)
#   * setup_repo (boolean): Whether to set up repository (Default: true)
#
class cloudstack::agent (
  $version      = $cloudstack::params::cloudstack_agent_version,
  $package_name = $cloudstack::params::cloudstack_agent_package,
  $setup_repo   = $cloudstack::params::cloudstack_agent_setup_repo,
) inherits cloudstack::params {
  # Validation
  validate_string($version, $package_name)
  validate_bool($setup_repo)

  # Setup Repository
  if ($setup_repo) {
    class  { 'cloudstack::install::repo':
      version => $version,
    }
  }

  # Install Package
  package { $package_name:
    ensure => $version,
  }
}
