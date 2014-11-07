require 'spec_helper'

describe 'cloudstack' do
  let(:facts) { {
  	:osfamily 			=> 'debian',
  	:operatingsystem 	=> 'Ubuntu',
  	:lsbdistid			=> 'Ubuntu',
  	:lsbdistcodename 	=> 'saucy',
  	:concat_basedir 	=> '/tmp'
  } }
  
  let(:params) { {
  	:database_server_key 	=> 'notsosecret',
  	:database_db_key 		=> 'notsosecret',
  } }

  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "with_defaults" do
	  it { should contain_class('cloudstack::install') }
	  it { should contain_class('cloudstack::install::cloudstack') }
	  it { should contain_class('cloudstack::install::nfs') }
	  it { should contain_class('cloudstack::install::mysql') }
	  
	  it { should contain_class('cloudstack::config') }
	  it { should contain_class('cloudstack::config::cloudstack') }
	  it { should contain_class('cloudstack::config::nfs') }
	  it { should contain_class('cloudstack::config::mysql') }

	  it { should contain_package('cloudstack-management') }  
	  
	  it { should contain_exec('wget-http://download.cloud.com.s3.amazonaws.com/tools/vhd-util') }
	  
	  it { should contain_class('mysql::server') }
	  
	  it { should contain_file('/etc/mysql/conf.d/cloudstack.cnf').with_content(/max_connections=350/) }
	  	  		
	  it { should contain_cloudstack__config__cloudstack__system_template('kvm') }	
	  it { should contain_cloudstack__config__cloudstack__system_template('xenserver') }	
	  
	  it { should contain_concat__fragment('create-sys-tpl-kvm') }
	  it { should contain_exec('Install System VM templates') }
	  
	  it { should contain_exec('Setup Cloudstack with MySQL database') }
	  	  
	  it { should contain_exec('Configure Cloudstack') }
  end
  
  context "cloudstack_install_disabled" do
	  let(:params) { {
	  	:database_server_key 	=> 'notsosecret',
	  	:database_db_key 		=> 'notsosecret',
	  	:cloudstack_install		=> false,
	  } }

	  it { should contain_class('cloudstack::install') }
	  it { should_not contain_class('cloudstack::install::cloudstack') }
	  it { should contain_class('cloudstack::install::nfs') }
	  it { should contain_class('cloudstack::install::mysql') }	  
  end
  
  context "redhat_no_nfs" do
	  let(:facts) { {
	  	:osfamily 			=> 'redhat',
	  	:operatingsystem 	=> 'CentOS',
	  	:concat_basedir 	=> '/tmp'
	  } }
	  
	  let(:params) { {
	  	:nfs_server		=> false,			# TODO TEST WITH NFS ENABLED -> BUG in NFS Module ?
	  } }
	  
	  it { should contain_package('cloudstack-management') }  
	  
  end  
end
