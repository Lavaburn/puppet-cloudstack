# Class: cloudstack::install::cloudstack
#
# This is a private class used by the 'cloudstack::install' class.
#
# Sets up the Cloudstack Repositories and
# installs CloudStack Management/Usage Server packages
#
# Module Dependencies:
#   * maestrodev-wget
#
class cloudstack::install::cloudstack (
  $setup_repos = $cloudstack::cloudstack_setup_repos,
  $version     = $cloudstack::cloudstack_version,

  $install_mgmt  = $cloudstack::cloudstack_install_mgmt,
  $install_usage = $cloudstack::cloudstack_install_usage,
  $mgmt_package  = $cloudstack::cloudstack_mgmt_package_name,
  $usage_package = $cloudstack::cloudstack_usage_package_name,

  $hypervisor_support = $cloudstack::hypervisor_support,
  $vhd_util_url       = $cloudstack::vhd_util_url,
  $vhd_util_path      = $cloudstack::vhd_util_path,

  $setup_dir = $cloudstack::cloudstack_setup_dir
) inherits cloudstack::install {
  # Validation
  validate_bool($setup_repos, $install_mgmt, $install_usage)
  validate_string($version, $vhd_util_url, $mgmt_package, $usage_package)
  validate_array($hypervisor_support)
  validate_absolute_path($vhd_util_path, $setup_dir)

  # Repository
  if ($setup_repos) {
    class  { 'cloudstack::install::repo':
      version => $version,
    }
  }

  # Packages
  if ($install_mgmt) {
    package { $mgmt_package:
      ensure => $version,
    }
  }

  if ($install_usage) {
    package { $usage_package:
      ensure => $version,
    }
  }

  if ($setup_repos and $install_mgmt) {
    Class['cloudstack::install::repo'] -> Package[$mgmt_package]
  }
  if ($setup_repos and $install_usage) {
    Class['cloudstack::install::repo'] -> Package[$usage_package]
  }

  # OS specific
  case $::osfamily {
    # 'redhat': {}
    'debian': {
      # Documented bug, fixed in 4.3.1 and 4.4.x
      if ($version =~ /^4.3.0/) {
        package { 'libmysql-java':
          ensure => 'installed',
        }
      }
    }
    default: {
      # Do Nothing
    }
  }

  # Hypervisor specific
  if ('xenserver' in $hypervisor_support) {
    include ::wget

    wget::fetch { $vhd_util_url:
      destination => "${vhd_util_path}/vhd-util",
    }

    if ($install_mgmt) {
      Package[$mgmt_package] -> Wget::Fetch[$vhd_util_url]
    }
  }

  # Version specific
  if ($install_mgmt and $version =~ /^4.4.0/) {
    # CS 4.4.0 - SQL Schema "premium" missing "use cloud"
    $patch_name = 'cs_4_4_0-schema-premium.patch'

    file { "${setup_dir}/${patch_name}":
      ensure => 'file',
      source => "puppet:///modules/cloudstack/patches/${patch_name}",
    }
    ->
    exec { "patch-${patch_name}":
      command     => "/usr/bin/patch -p1 ${setup_dir}/create-schema-premium.sql < ${setup_dir}/${patch_name}",
      cwd         => $setup_dir,
      refreshonly => true,
      subscribe   => Package[$mgmt_package],
    }
  }
}
