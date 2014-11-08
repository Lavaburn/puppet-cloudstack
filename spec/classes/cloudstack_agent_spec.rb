require 'spec_helper'

describe 'cloudstack::agent' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "ubuntu_defaults" do
  	  let(:facts) { {
	  	:osfamily 			=> 'debian',
	  	:operatingsystem 	=> 'Ubuntu',
	  	:lsbdistid			=> 'Ubuntu',
	  	:lsbdistcodename 	=> 'saucy',
	  	:concat_basedir  	=> '/tmp',
	  } }
	  
	  it { should compile.with_all_deps }
	  
  	  it { should contain_apt__source('cloudstack').with({
      	'release' 	=> 'precise',
      	'repos' 	=> '4.4',
      }) }	 
  	  it { should contain_package('cloudstack-agent') }  	  
  end
  
  context "centos_defaults" do
  	let(:facts) { {
	    :osfamily 				=> 'redhat',
	  	:operatingsystem 		=> 'CentOS',
	  	:operatingsystemrelease => '6.0',
	  	:concat_basedir  		=> '/tmp',
	} }
    
  	it { should compile.with_all_deps }
  	
  	it { should contain_file('/etc/yum.repos.d/cloudstack.repo').with_content(/baseurl=http:\/\/cloudstack.apt-get.eu\/rhel\/4.4/) }	  	  	
    it { should contain_package('cloudstack-agent') }  	  
  end
end
