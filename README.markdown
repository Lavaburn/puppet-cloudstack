# Puppet Module for Apache Cloudstack

####Table of Contents

1. [Overview](#overview)
2. [Dependencies](#dependencies)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Compatibility](#compatibility)
6. [Testing](#testing)

##Overview

This module installs and sets up Apache Cloudstack for first use.
   

##Dependencies

CloudStack Infrastructure depends on a working NTP server. 
Ensure NTP is installed and set up before calling cloudstack class.

Modules:
- puppetlabs/stdlib (REQUIRED)
- puppetlabs/mysql (Optional)
- haraldsk/nfs (Optional)
- maestrodev/wget (Optional)
- puppetlabs/apt (Optional)
- puppetlabs/concat (Optional)

* If you want to set up MySQL config:
  	- include 'mysql::server'	[puppetlabs/mysql]
* If you want to set up NFS:
  	- include 'nfs::server'		[haraldsk/nfs]
* If you need XenServer support:
  	- include 'wget'			[maestrodev/wget]
* If you're installing on Debian:
	- include 'apt'				[puppetlabs/apt]
* If you're installing the master server:
	[puppetlabs/concat]
* If you manage Cloudstack without installing it:
	Package[cloudstack_mgmt_package_name] should exist

Notes:
Due to incompatibility issues on Ubuntu 14.04, I use a different version of haraldsk/nfs:
On Github: haw-hh-ai-lab/nfs [Branch = fix_debian_service_cycle_squashed]


##Usage

It is highly recommended to put secret keys in Hiera-eyaml and use automatic parameter lookup
	[https://github.com/TomPoulton/hiera-eyaml]
	[https://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup]

Make sure to include all dependencies as per above.

Also see the examples/profile.pp file for an example on how to set up dependencies.


### Single Server Setup
  class { 'cloudstack':
    hostname_cloudstack          => '192.168.1.1',

    database_server_key           => 'notsecretnow', # (*)
    database_database_key         => 'notsecretnow', # (*)
    database_password             => 'notsecretnow', # (*)

    hypervisor_support            => ['xenserver', 'kvm', 'lxc'],
    cloudstack_server_count       => 1,
  }

### 3 Server Setup
  # Cloudstack - MySQL only
  class { 'cloudstack':
    cloudstack_server             => false,
    nfs_server                    => false,
    
    cloudstack_server_count       => 2,
  }

  # Cloudstack - NFS only
  class { 'cloudstack':
    cloudstack_server   => false,
    mysql_server        => false,
  }

  # Cloudstack - Cloudstack Server only
  class { 'cloudstack':
    nfs_server                    => false,
    mysql_server                  => false,

    hostname_cloudstack           => '192.168.1.1',
    hostname_database             => '192.168.1.2',
    hostname_nfs                  => '192.168.1.3',

    database_server_key           => 'notsecretnow', # (*)
    database_database_key         => 'notsecretnow', # (*)
    database_password             => 'notsecretnow', # (*)

    hypervisor_support            => ['xenserver', 'kvm', 'lxc'],
  }

  # Cloudstack - Second Cloudstack Server
  class { 'cloudstack':
    nfs_server                    => false,
    mysql_server                  => false,

    hostname_cloudstack           => '192.168.1.4',
    hostname_database             => '192.168.1.2',
    hostname_nfs                  => '192.168.1.3',

    database_server_key           => 'notsecretnow', # (*)
    database_database_key         => 'notsecretnow', # (*)
    database_password             => 'notsecretnow', # (*)

    cloudstack_master             => false,
  }
  
### Redundancy/HA
  You can add any number of Cloudstack servers (see Usage/Cloudstack - Second Cloudstack Server)
  - Make sure to change the cloudstack_server_count on the MySQL Server
  - Make sure to set cloudstack_master to false
  
  For MySQL HA, refer to MySQL documentation

##Reference

You should only use the 'cloudstack' class.

##Compatibility

This module has been tested with:
- Puppet 3.7.3 - Ruby 1.9.3 - Ubuntu 14.04.1
- Puppet 3.7.3 - Ruby 1.8.7 - CentOS 6.3

##Testing

Dependencies:
- Ruby
- Bundler (gem install bundler)

If you wish to test this module yourself:
1. bundle
2. rake test

For running acceptance testing (beaker/vagrant):
1. rake acceptance
(TODO - DEPENDENCIES)