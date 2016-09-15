# Puppet Module for Apache Cloudstack

####Table of Contents

1. [Overview](#overview)
2. [Dependencies](#dependencies)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Compatibility](#compatibility)
6. [Testing](#testing)
7. [Copyright] (#copyright)

##Overview

This module installs and sets up Apache Cloudstack for first use.
It also contains custom types to manage Cloudstack using the REST API
   

##Dependencies

CloudStack Infrastructure depends on a working NTP server. 
Ensure NTP is installed and set up before calling cloudstack class.

Modules:
- puppetlabs/stdlib (REQUIRED)
- echocat/nfs (Optional)
- puppetlabs/mysql (Optional)
- puppetlabs/apt (Optional / Ubuntu)
- maestrodev/wget (Optional / XenServer support)
- puppetlabs/concat (Optional / CS Master)
- stahnma/epel (Optional / Cloudmonkey / CentOS)

* If you want to set up MySQL config:
  	- include 'mysql::server'	[puppetlabs/mysql]
* If you want to set up NFS:
  	- include 'nfs::server'		[haraldsk/nfs]

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

##Compatibility

This module is compatible with Cloudstack 4.x

This module is compatible with:
  * Ubuntu 12.04 LTS and 14.04 LTS
  * CentOS 6.x and 7.x
(RHEL 6 and 7 can be easily added)

This module has been tested on: 
	- Puppet 3.7.3 (Ruby 1.9.3)
	- Puppet 4.3.2 (Ruby 2.1.8)

##Testing

Dependencies:
- Ruby
- Bundler (gem install bundler)

If you wish to test this module yourself:
1. bundle
2. rake test

For running acceptance testing (beaker/vagrant):
1. rake acceptance

##Copyright

   Copyright 2014 Nicolas Truyens

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
