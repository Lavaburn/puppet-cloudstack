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

This module does not depend on anything.

##Usage

To begin with the standard configuration, use:
class 'cloudstack' {

}

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