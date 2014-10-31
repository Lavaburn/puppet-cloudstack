# Class: cloudstack::config::nfs
#
# Configures NFS server
#
# Parameters:
#  These flags can be turned off to integrate with other puppet modules.
#   TODO No Flags?
#
# When using the main "cloudstack" class, use Hiera Data Bindings
# to disable the compatibility flags.
#
#  Normal configuration (taken over from cloudstack class)
#   * nfs_exports (array): See 'cloudstack' class
#
class cloudstack::config::nfs (
  $nfs_exports              = $::cloudstack::nfs_exports,
  $create_system_templates  = $::cloudstack::create_system_templates,
) {
  # Validation
  validate_array($nfs_exports)
  validate_bool($create_system_templates)

  $root_dir = '/exports'

  # Require NFS puppet module

  # file /exports => directory

  # file /exports/$nfs_exports => directory

  				# vi /etc/exports
				  #     /exports  *(rw,async,no_root_squash,no_subtree_check)

				  # exportfs -a

				  # NFSv4: ON NFS SERVER AND ALL HYPERVISORS !!!
				  # vi /etc/idmapd.conf
				  #   Domain = company.com


}
