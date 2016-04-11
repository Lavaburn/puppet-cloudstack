require 'spec_helper'

describe 'cloudstack' do
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
	     class { '::apt': }"
	  }
	  
	  context "defaults" do	  
      let(:params) {{
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password'
      }}
      
		  it { should compile.with_all_deps }
	  
		  it { should contain_class('cloudstack::install::cloudstack') }
		  
		  it { should contain_class('cloudstack::config::cloudstack') }
		  it { should contain_class('cloudstack::config::nfs') }
		  it { should contain_class('cloudstack::config::mysql') }
	 
	 	  # Cloudstack Install
	      it { should contain_apt__source('cloudstack').with({
	      	'release' 	=> 'precise',
	      	'repos' 	  => '4.4',
	      }) }	  
		  it { should contain_package('cloudstack-management') }  	  
		  it { should contain_exec('wget-http://download.cloud.com.s3.amazonaws.com/tools/vhd-util') }
		  
		  # Cloudstack Setup
		  it { should contain_exec('Setup Cloudstack with MySQL database') }
		  it { should contain_exec('Configure Cloudstack') }
		  it { should contain_concat__fragment('create-sys-tpl-kvm') }
		  it { should contain_exec('Install System VM templates') }
		  	  
		  # NFS Setup
		  it { should contain_nfs__server__export('/exports/secondary') }
		  
		  # MySQL Setup
		  it { should contain_file('/etc/mysql/conf.d/cloudstack.cnf').with_content(/max_connections=350/) }
    end
      
    context "without_cloudstack" do
      let(:params) { {
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password',
		  	:cloudstack_server	   => false,		  	
		  } }
		  
		  it { should compile.with_all_deps }
		  
		  
		  it { should_not contain_class('cloudstack::install::cloudstack') }
		  
		  it { should_not contain_class('cloudstack::config::cloudstack') }
		  it { should contain_class('cloudstack::config::nfs') }
		  it { should contain_class('cloudstack::config::mysql') }
	  end
	  
	  context "without_mysql" do
      let(:params) { {		  	
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password',
		  	:mysql_server		       => false,		  	
		  } }
	  
		  it { should compile.with_all_deps }	
	  
	  
		  it { should contain_class('cloudstack::install::cloudstack') }
		  
		  it { should contain_class('cloudstack::config::cloudstack') }
		  it { should contain_class('cloudstack::config::nfs') }
		  it { should_not contain_class('cloudstack::config::mysql') }
	  end
	  
	  context "without_nfs" do
      let(:params) { {
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password',
		  	:nfs_server		         => false,		  	
		  } }
		  
		  it { should compile.with_all_deps }	
		  
	  
		  it { should contain_class('cloudstack::install::cloudstack') }
		  
		  it { should contain_class('cloudstack::config::cloudstack') }
		  it { should_not contain_class('cloudstack::config::nfs') }
		  it { should contain_class('cloudstack::config::mysql') }
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
  	   class { '::wget': }"
  	}
  	
    context "defaults" do 
      let(:params) { {
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password',  
      } }
        
      it { should compile.with_all_deps }
    
    	it { should contain_class('cloudstack::install::cloudstack') }
    
    	it { should contain_class('cloudstack::config::cloudstack') }
    	it { should contain_class('cloudstack::config::nfs') }
    	it { should contain_class('cloudstack::config::mysql') }
          
     # Cloudstack Install
    	it { should contain_file('/etc/yum.repos.d/cloudstack.repo').with_content(/baseurl=http:\/\/cloudstack.apt-get.eu\/rhel\/4.4/) }	  	  	
    	it { should contain_package('cloudstack-management') }  	  
    	it { should contain_exec('wget-http://download.cloud.com.s3.amazonaws.com/tools/vhd-util') }
    	
    	# NFS Install
      it { should contain_class('nfs::server') }	  
    
    	# MySQL Install
    	it { should contain_class('mysql::server') }	
    	  	
    	# Cloudstack Setup
    	it { should contain_exec('Setup Cloudstack with MySQL database') }
    	it { should contain_exec('Configure Cloudstack') }
    	it { should contain_concat__fragment('create-sys-tpl-kvm') }
    	it { should contain_exec('Install System VM templates') }
    	  
    	# NFS Setup
    	it { should contain_nfs__server__export('/exports/secondary') }	
    	  
    	# MySQL Setup
    	it { should contain_file('/etc/my.cnf.d/cloudstack.cnf').with_content(/max_connections=350/) }	
    end
  end  
end
