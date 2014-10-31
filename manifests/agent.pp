# Class: cloudstack::agent
#
# This module installs Apache CloudStack Agent
# (to be run on Hypervisor)
#
# Parameters:
#  TODO
#
class cloudstack::agent (
  # TODO

  # Installation source flags
  $cloudstack_install_source = 'apache',

	# Versioning
	$cloudstack_install_version = 'latest',

  # Deployment information ???
  # TODO CLOUDSTACK IPS (localhost) => HIERA !!
  # TODO MYSQL IPS (localhost)      => HIERA !!
  # TODO NFS IPS (localhost)        => HIERA !!

) {
  # THIS CAN BE TESTED ON CITRIX XENSERVER TO START OFF

  # MANUAL: NTP ?

  #

  # TODO
  #   yum -y install cloudstack-agent
}
