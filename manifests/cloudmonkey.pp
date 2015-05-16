# Class: cloudstack::cloudmonkey
#
# This will install the CloudMonkey CLI
# You will need 'pip' installed - I did not include it here as a dependency.
#
class cloudstack::cloudmonkey inherits ::cloudstack {
  # If you don't have 'pip' installed:
#    puppet module install stankevich-python
#    class { 'python' :
#		   pip => true,
#		 }

  python::pip { 'cloudmonkey' :
    ensure  => 'present',
    pkgname => 'cloudmonkey',
  }
}
