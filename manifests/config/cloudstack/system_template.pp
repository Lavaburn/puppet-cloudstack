# Define: cloudstack::config::cloudstack::system_template
#
# Installs a Cloudstack System VM Template
#
# Parameters:
#   * $directory (string): Directory where to store the System VM Templates
#     This should be a mount for NFS Secondary Storage. Default = /tmp
#
define cloudstack::config::cloudstack::system_template (
  $directory = '/tmp',
) {
  include cloudstack::params

  $installer_bin  = $cloudstack::params::system_template_installer_bin
  $template_url   = $cloudstack::params::system_template_url
  $image_version  = $cloudstack::params::system_template_image_version

  case $title {
    'hyperv': {
      $image = "systemvm64template-${image_version}-hyperv.vhd"
      $hypervisor = 'hyperv'
    }
    'xenserver': {
      $image = "systemvm64template-${image_version}-xen.vhd.bz2"
      $hypervisor = 'xenserver'
    }
    'vmware': {
      $image = "systemvm64template-${image_version}-vmware.ova"
      $hypervisor = 'vmware'
    }
    'kvm': {
      $image = "systemvm64template-${image_version}-kvm.qcow2.bz2"
      $hypervisor = 'kvm'
    }
    'lxc': {
      $image = "systemvm64template-${image_version}-kvm.qcow2.bz2"
      $hypervisor = 'lxc'
    }
    default: {
      fail("${title} is not a supported hypervisor.")
      fail('Select one of: hyper-v, xenserver, vsphere, kvm, lxc')
    }
  }

  exec { "Install System VM template for ${hypervisor}":
    command   => "${installer_bin} -m ${directory} -u ${template_url}/${image} -h ${hypervisor} -F",
    subscribe   => Package[$cloudstack::params::cloudstack_package_name], # TODO What happens if not installed from package??
    refreshonly => true
  }
}
