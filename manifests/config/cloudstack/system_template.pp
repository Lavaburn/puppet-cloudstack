# Definition: cloudstack::config::cloudstack::system_template
#
# Installs a Cloudstack System VM Template
#
# Parameters:
#   * [title] (string): hypervisor type ['hyperv', 'xenserver', 'vmware', 'kvm', 'lxc']
#   * script (string): Path where installer script should be created.
#   * image_version (string): Version number for the System Templates.
#   * installer_bin (absolute path): Path to cloud-install-sys-tmplt
#   * directory (absolute path): Directory where to store the System VM Templates
#   * template_url (string/URL): URL for system templates
#
# Example:
# cloudstack::config::cloudstack::system_template { 'hyperv':
#   script          => '/usr/share/cloudstack-common/scripts/installer/create-sys-tpl.sh',
#   image_version   => '4.4.1-7',
#   installer_bin   => '/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt',
#   directory       => '/mnt/secondary',
#   template_url    => 'http://cloudstack.apt-get.eu/systemvm/4.4',
# }
# => This will download the system templates for Hyper-V
#
define cloudstack::config::cloudstack::system_template (
  $script,
  $image_version,
  $installer_bin,
  $directory,
  $template_url,
) {
  # Validation
  validate_string($title, $image_version)
  validate_absolute_path($script)

  # Validation - these parameters are used in the template
  validate_absolute_path($installer_bin, $directory)
  validate_string($template_url)

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
      $order = '30'                     # 'vsphere' never used?
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
      fail('Select one of: hyper-v, xenserver, vmware, kvm, lxc')
    }
  }

  concat::fragment { "create-sys-tpl-${hypervisor}":
    target  => $script,
    content => template('cloudstack/system_template/create.erb'),
    order   => $order,
  }
}
