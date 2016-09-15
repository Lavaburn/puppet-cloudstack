# Class: cloudstack::cloudmonkey
#
# This class installs CloudMonkey CLI (Python PIP package)
#
# Parameters:
#   * version (string): Version of the package (Default: present)
#   * package_name (string): Package name (Default: cloudmonkey)
#   * setup_python (boolean): Whether to set up python (and pip) (Default: false)
#
# Module Dependencies
#   * stankevich-python
#
class cloudstack::cloudmonkey (
  $version      = $cloudstack::params::cloudmonkey_version,
  $package_name = $cloudstack::params::cloudmonkey_package_name,
  $setup_python = $cloudstack::params::cloudmonkey_setup_python,
) inherits cloudstack::params {
  # Validation
  validate_string($version, $package_name)
  validate_bool($setup_python)

  # Dependencies
  if ($setup_python) {
    class { 'python' :
      pip => true,
    }
  }

  # Install Package
  python::pip { $package_name:
    ensure  => $version,
    pkgname => $package_name,
  }
}
