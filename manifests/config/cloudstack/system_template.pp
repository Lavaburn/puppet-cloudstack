# Definition: cloudstack::config::cloudstack::system_template
#
# This is a private definition used by the 'cloudstack::config::cloudstack' class.
#
# Installs a Cloudstack System VM Template
#
# Parameters:
#   * [title] (string): hypervisor type ['hyperv', 'xenserver', 'vmware', 'kvm', 'lxc']
#   * script (string): Path where installer script should be created.
#   * installer_bin (absolute path): Path to cloud-install-sys-tmplt
#   * directory (absolute path): Directory where to store the System VM Templates
#   * base_url (string/URL): URL for system templates (unversioned)
#   * server_version (string): Version of the Management Server installed
#
# Example:
# cloudstack::config::cloudstack::system_template { 'hyperv':
#   script          => '/usr/share/cloudstack-common/scripts/installer/create-sys-tpl.sh',
#   installer_bin   => '/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt',
#   directory       => '/mnt/secondary',
#   base_url        => 'http://cloudstack.apt-get.eu/systemvm',
#   server_version   => '4.4.4',
# }
# => This will download the system templates for Cloudstack 4.4.4 supporting the Hyper-V hypervisor
#
define cloudstack::config::cloudstack::system_template (
  $script,
  $installer_bin,
  $directory,
  $base_url,
  $server_version,
) {
  # Validation
  validate_absolute_path($script, $installer_bin, $directory)
  validate_string($base_url, $server_version)

  #Template Parameters
  $hypervisor = $title

  case $hypervisor {
    'hyperv': {
      $order = '20'
    }
    'xenserver': {
      $order = '25'
    }
    'vmware': {
      $order = '30'
    }
    'kvm': {
      $order = '35'
    }
    'lxc': {
      $order = '40'
    }
    default: {
      fail("${hypervisor} is not a supported hypervisor. Expected one of: hyperv, xenserver, vmware, kvm, lxc")
    }
  }

  if versioncmp($server_version, '4.3.0') < 0 {
    warning("SystemVM Templates for Cloudstack ${server_version} are no longer supported! Using 4.3, but this will likely fail.")
  }

  if versioncmp($server_version, '4.4') < 0 {
    $image_version_major = '4.3'
  } elsif versioncmp($server_version, '4.5') < 0 {
    if versioncmp($server_version, '4.4.0') > 0 {
      $image_version = '4.4.1-7'
    } else {
      $image_version = '4.4.0-6'
    }
    $image_version_major = '4.4'
  } elsif versioncmp($server_version, '4.6') < 0 {
    $image_version       = '4.5'
    $image_version_major = '4.5'
  } else {
    $image_version       = '4.6.0'
    $image_version_major = '4.6'
  }

  case $hypervisor {
    'hyperv': {
      if versioncmp($server_version, '4.4') < 0 {
        fail("Cloudstack ${server_version} does not support HyperV SystemVM Templates!")
      }
      $image = "systemvm64template-${image_version}-hyperv.vhd.zip"
    }
    'xenserver': {
      if versioncmp($server_version, '4.4') < 0 {
        $image_version = '2014-06-23-master'
      }
      $image = "systemvm64template-${image_version}-xen.vhd.bz2"
    }
    'vmware': {
      if versioncmp($server_version, '4.4') < 0 {
        fail("Cloudstack ${server_version} does not support VMware SystemVM Templates!")
      }
      $image = "systemvm64template-${image_version}-vmware.ova"
    }
    'kvm': {
      if versioncmp($server_version, '4.4') < 0 {
        $image_version = '2015-01-28-4.3'
      }
      $image = "systemvm64template-${image_version}-kvm.qcow2.bz2"
    }
    'lxc': {
      if versioncmp($server_version, '4.4') < 0 {
        $image_version = '2015-01-28-4.3'
      }
      $image = "systemvm64template-${image_version}-kvm.qcow2.bz2"
    }
    default: {
      # Do Nothing
    }
  }

  $template_url = "${base_url}/${image_version_major}/${image}"

  # Create Template
  concat::fragment { "create-sys-tpl-${hypervisor}":
    target  => $script,
    content => template('cloudstack/system_template/create.erb'),
    order   => $order,
  }
}
