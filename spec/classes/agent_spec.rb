require 'spec_helper'

describe 'cloudstack::agent' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "ubuntu" do
  	  let(:facts) { {
	  	:osfamily 			   => 'debian',
	  	:operatingsystem 	 => 'Ubuntu',
	  	:lsbdistid			   => 'Ubuntu',
	  	:lsbdistcodename 	 => 'saucy',
	  	:concat_basedir  	 => '/tmp',
	  } }
    	  
	  context "defaults" do	  
	    it { should compile.with_all_deps }

      it { should contain_apt__source('cloudstack') }
      it { should contain_package('cloudstack-agent') }
    end
  end
  
  context "centos" do
  	let(:facts) { {
	    :osfamily 				       => 'redhat',
	  	:operatingsystem 		     => 'CentOS',
	  	:operatingsystemrelease  => '6.0',
	  	:concat_basedir  		     => '/tmp',
  	} }
        
    context "defaults" do   
      it { should compile.with_all_deps }

      it { should contain_file('/etc/yum.repos.d/cloudstack.repo') }
      it { should contain_package('cloudstack-agent') }
    end 
  end  
end
