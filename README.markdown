# Puppet Module for Apache Cloudstack

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Dependencies](#dependencies)
4. [Usage](#usage)
5. [Reference](#reference)
6. [Compatibility](#compatibility)
7. [Testing](#testing)

##Overview

This module manages Apache Cloudstack.   

##Module Description

This module can install and configure Apache Cloudstack

##Dependencies

CloudStack Infrastructure depends on a working NTP server. 
This module does *NOT* provide NTP.

This module depends on:
* puppetlabs/stdlib
* (OPTIONAL) puppetlabs/apt
* (OPTIONAL) puppetlabs/mysql
* (OPTIONAL) maestrodev/wget
* (OPTIONAL) haraldsk/nfs

##Usage

### Single Server Setup

The default configuration will install a stand-alone management server
and set up the MySQL Database.
class 'cloudstack' {

}
TODO

### 3 Server Setup
TODO


### Redundancy/HA
TODO


##Reference

Here, list the classes, types, providers, facts, etc contained in your module.

##Compatibility

This module has been tested with:
- Puppet x.x
- Ruby x.x
- Ubuntu x.x

##Testing

Dependencies:
- Ruby
- Bundler (gem install bundler)

If you wish to test this module yourself:
1. bundle
2. rake test