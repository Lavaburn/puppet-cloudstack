# Class: cloudstack::install::mysql
#
# Installs MySQL package
#
# Parameters:
#  These flags can be turned off to integrate with other puppet modules.
#   * include_mysql_server (boolean): Whether to include mysql::server class.
#     Default = true
#
# When using the main "cloudstack" class, use Hiera Data Bindings
# to disable the compatibility flags.
#
#  Normal configuration (taken over from cloudstack class)
#   * install_source (string): See 'cloudstack' class
#   * install_version (string): See 'cloudstack' class
#   * mysql_class_override_options (hash): See 'cloudstack' class
#
class cloudstack::install::mysql (
  # User Configuration
  $install_source     = $::cloudstack::mysql_install_source,
  $install_version    = $::cloudstack::mysql_install_version,
  $override_options   = $::cloudstack::mysql_class_override_options,
) {
  # Validation
  validate_re($install_source, [ '^puppet$' ])
  validate_string($install_version)

  if ($install_version != 'latest') {
     fail('Version selection is not yet supported. Use install_version = "latest"')
  }

  case $install_source {
    'puppet': {
		  class { 'mysql::server':
		    override_options => $override_options
		  }
    }
    default: {
      fail('Only Puppet Module puppetlabs/mysql is supported. Use install_source = "puppet"')
    }
  }
}
