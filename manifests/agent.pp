# Class: cloudstack::agent
#
# This module installs Apache CloudStack Agent
# (to be run on Hypervisor)
#
# Parameters:
#  TODO AGENT - PARAMS
#
class cloudstack::agent (
  # Installation source flags
  $cloudstack_install_source = 'apache',

	# Versioning
	$cloudstack_install_version = 'latest',
) {
  include cloudstack::params

  # TODO [COMPATIBILITY: Test on XenServer/Redhat/Debian/...]

  # TODO AGENT - PACKAGE INSTALL
  #   yum -y install cloudstack-agent
}
