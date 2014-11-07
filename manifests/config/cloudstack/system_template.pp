# Define: cloudstack::config::cloudstack::system_template
#
# Installs a Cloudstack System VM Template
#
# Parameters:
#   * directory (string): Directory where to store the System VM Templates
#     This should be a mount for NFS Secondary Storage. Default = /tmp
#   * script (string): Path where script should be created to create the templates.
#     Default = /tmp/create-sys-tpl.sh
#   * major_version (string): Cloudstack Version (4.0 - 4.4)
#
define cloudstack::config::cloudstack::system_template (
  $directory      = '/tmp',
  $script         = '/tmp/create-sys-tpl.sh',
  $major_version  = $cloudstack::config::cloudstack::major_version,
) {
  include cloudstack::params

  $installer_bin  = $cloudstack::params::system_template_installer_bin
  $template_url   = $cloudstack::params::system_template_url[$major_version]
  $image_version  = $cloudstack::params::system_template_image_version[$major_version]

  case $title {
    'hyperv': {
      $image = "systemvm64template-${image_version}-hyperv.vhd"
      $hypervisor = 'hyperv'
      $order = '20'
    }
    'xenserver': {
      $image = "systemvm64template-${image_version}-xen.vhd.bz2"
      $hypervisor = 'xenserver'
      $order = '25'
    }
    'vmware': {
      $image = "systemvm64template-${image_version}-vmware.ova"
      $hypervisor = 'vmware'
      $order = '30'
    }
    'kvm': {
      $image = "systemvm64template-${image_version}-kvm.qcow2.bz2"
      $hypervisor = 'kvm'
      $order = '35'
    }
    'lxc': {
      $image = "systemvm64template-${image_version}-kvm.qcow2.bz2"
      $hypervisor = 'lxc'
      $order = '40'
    }
    default: {
      fail("${title} is not a supported hypervisor.")
      fail('Select one of: hyper-v, xenserver, vsphere, kvm, lxc')
    }
  }

  concat::fragment { "create-sys-tpl-${hypervisor}":
    target  => $script,
    content => "${installer_bin} -m ${directory} -u ${template_url}/${image} -h ${hypervisor} -F",
    order   => $order,
  }
}
