require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.hiera_config = File.join(fixture_path, 'hiera/hiera.yaml')
end


RSpec.configure do |c|
  c.before do 
    @ubuntu_facts = {
      :kernel                    => 'Linux',
      :osfamily                  => 'Debian',
      :operatingsystem           => 'Ubuntu',
      :operatingsystemrelease    => '14.04',
      :operatingsystemmajrelease => '14.04',
      
      # LSB Utils
      :lsbdistid                 => 'Ubuntu',
      :lsbdistcodename           => 'trusty',
      :lsbdistrelease            => '14.04',
      
      # Concat
      :concat_basedir            => '/tmp',
      :id                        => 'root',
      :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      
      # WGET
      :http_proxy                => '',
      :https_proxy               => '',
        
#      :processorcount            => 1,                 # Monit
#      :memorysize                => '2.00 GB',         # Memcache
#
#      :domain                    => 'rcswimax.com',
#      :public_ipv4               => '192.168.100.200', # DNS Role ??
#      :ipaddress                 => '192.168.1.1',
#        
#      :clientcert                => 'ubuntu',          # For Hiera
#      :fqdn                      => 'ubuntu.rcswimax.com',  # Elasticsearch
#  
      :puppetversion             => '4.3.2',
#      :facterversion             => '2.2.1',
#      :interfaces                => 'lo,eth0',
#      :blockdevices              => 'sda,sr0',
#      :rubysitedir               => '/opt/puppetlabs/puppet/a/b/c',
#      :php_version               => '5.4',  
#      :freeradius_version        => '2',
#      :virtualenv_version        => '1.11.4',
#      :collectd_version          => '5.4.0-git',
#      :dashboard_version         => '2.0.0-beta1',
#      :augeasversion             => '1.2.0',      # kmod
    }
    
    @centos_facts = {
      :kernel                    => 'Linux',
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :operatingsystemrelease    => '7.0',
      :operatingsystemmajrelease => '7',

      # LSB Utils
      :lsbdistcodename           => 'Core',
      :lsbdistid                 => 'CentOS',
      :lsbdistrelease            => "7.1.1503",
      :lsbmajdistrelease         => '7',
      :lsbminordistrelease       => '1',
          
      # Concat
      :concat_basedir            => '/tmp',
      :id                        => 'root',
      :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',

      # WGET
      :http_proxy                => '',
      :https_proxy               => '',
        
#      :processorcount            => 1,                # Monit
#      :memorysize                => '2.00 GB',        # Memcache
#
#      :domain                    => 'rcswimax.com',
#      :public_ipv4               => '192.168.100.200',  # DNS Role ??
#      :ipaddress                 => '192.168.1.1',
#        
#      :clientcert                => 'centos',           # For Hiera
#      :fqdn                      => 'centos.rcswimax.com',  # Elasticsearch

#
      :puppetversion             => '4.3.2',
#      :facterversion             => '2.2.1',
#      :interfaces                => 'lo,eth0',
#      :blockdevices              => 'sda,sr0',  
#      :rubysitedir               => '/opt/puppetlabs/puppet/a/b/c', 
#      :php_version               => '5.4',
#      :sudoversion               => '1.7.3',    
#      :freeradius_version        => '2',
#      :virtualenv_version        => '1.11.4',
#      :collectd_version          => '5.4.0-git',
#      :dashboard_version         => '2.0.0-beta1',
#      :augeasversion             => '1.2.0',      # kmod
    }
  end
end