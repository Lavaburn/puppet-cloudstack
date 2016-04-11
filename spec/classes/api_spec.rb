require 'spec_helper'

describe 'cloudstack::api' do
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
    
    let(:pre_condition) { 
      "class { '::mysql::server': }
      class { '::nfs::server': }
      class { '::wget': }
      class { '::apt': }
      class { '::cloudstack': 
        database_password     => 'password',
        database_server_key   => 'password',
        database_database_key => 'password', 
      }"
    }
	  
	  context "defaults" do	  
      let(:params) {{
        :api_key    => 'password',
        :api_secret => 'password'
      }}
      
		  it { should compile.with_all_deps }

      it { should contain_file('/etc/cloudstack/api.yaml') }
		  it { should contain_package('rest-client') }
    end
  end
  
  context "centos" do
  	let(:facts) { {
	    :osfamily 				       => 'redhat',
	  	:operatingsystem 		     => 'CentOS',
	  	:operatingsystemrelease  => '6.0',
	  	:concat_basedir  		     => '/tmp',
  	} }
    
    let(:pre_condition) { 
      "class { '::mysql::server': }
      class { '::nfs::server': }
      class { '::wget': }
      class { '::cloudstack': 
        database_password     => 'password',
        database_server_key   => 'password',
        database_database_key => 'password', 
      }"
    }

    context "defaults" do   
      let(:params) {{
        :api_key    => 'password',
        :api_secret => 'password'
      }}
      
      it { should compile.with_all_deps }

      it { should contain_file('/etc/cloudstack/api.yaml') }
      it { should contain_package('rest-client') }
    end
  end  
end
