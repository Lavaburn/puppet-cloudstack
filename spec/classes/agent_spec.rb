require 'spec_helper'

describe 'cloudstack::agent' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "ubuntu" do
    let(:facts) {
        @ubuntu_facts
    }
    	  
	  context "defaults" do	  
	    it { should compile.with_all_deps }

      it { should contain_class('cloudstack::install::repo') }
        it { should contain_class('cloudstack::install::repo::apt') }
          it { should contain_class('apt') }
          it { should contain_apt__source('cloudstack').with({
            'location' => 'http://cloudstack.apt-get.eu/ubuntu',
            'release'  => 'trusty',
            'repos'    => '4.9',
          }) }
      it { should contain_package('cloudstack-agent') }
    end
  end
  
  context "centos" do
    let(:facts) {  
      @centos_facts
    }
        
    context "defaults" do   
      it { should compile.with_all_deps }

      it { should contain_class('cloudstack::install::repo') }
        it { should contain_class('cloudstack::install::repo::yum') }
        it { should contain_yumrepo('cloudstack').with({
          'baseurl'  => 'http://cloudstack.apt-get.eu/centos/7/4.9',
          'gpgcheck' => true,
        }) }
      it { should contain_package('cloudstack-agent') }
    end 
  end  
end
