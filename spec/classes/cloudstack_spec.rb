require 'spec_helper'

describe 'cloudstack' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "ubuntu" do
  	let(:facts) {
        @ubuntu_facts
	  }
	  
	  let(:pre_condition) { 
	    "class { '::mysql::server': }
	     class { '::nfs::server': }"
	  }
	  
	  context "defaults" do	  
      let(:params) {{
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password'
      }}
      
		  it { should compile.with_all_deps }
		    
		  # Installation
      it { should contain_class('cloudstack::install') }
        it { should contain_class('cloudstack::install::cloudstack') }
          it { should contain_class('cloudstack::install::repo') }
            it { should contain_class('cloudstack::install::repo::apt') }
              it { should contain_class('apt') }
              it { should contain_apt__source('cloudstack').with({
                'release' => 'trusty',
                'repos'   => '4.9',
              }) }   
            it { should_not contain_class('cloudstack::install::repo::yum') }
          it { should contain_package('cloudstack-management') }    
          it { should_not contain_package('cloudstack-usage') }
          it { should_not contain_package('libmysql-java') }
          it { should contain_class('wget') }
          it { should contain_wget__fetch('http://download.cloud.com.s3.amazonaws.com/tools/vhd-util') }
          it { should_not contain_file('/usr/share/cloudstack-management/setup/cs_4_4_0-schema-premium.patch') }
          it { should_not contain_exec('patch-cs_4_4_0-schema-premium.patch') }
             
      # Configuration
      it { should contain_class('cloudstack::config') }
        it { should contain_class('cloudstack::config::nfs') }
          it { should contain_file('/exports') }
          it { should contain_cloudstack__config__nfs__export('secondary') }
            it { should contain_file('/exports/secondary') }
            it { should contain_nfs__server__export('/exports/secondary') }
          
        it { should contain_class('cloudstack::config::mysql') }
          it { should contain_file('/etc/mysql/conf.d/cloudstack.cnf').with_content(/max_connections=350/) }
          
        it { should contain_class('cloudstack::config::cloudstack') }
          it { should contain_class('cloudstack::config::cloudstack::mysql') }
            it { should contain_exec('Setup Cloudstack with MySQL database') }
          it { should contain_exec('Configure Cloudstack') }
          it { should contain_concat('/usr/share/cloudstack-common/scripts/installer/create-sys-tpl.sh') }
          it { should contain_concat__fragment('create-sys-tpl-mount') }
          it { should contain_concat__fragment('create-sys-tpl-unmount') }
          it { should contain_cloudstack__config__cloudstack__system_template('kvm') }
            it { should contain_concat__fragment('create-sys-tpl-kvm') }
          it { should contain_exec('Install System VM templates') }
      
      # Service
      it { should contain_class('cloudstack::service') }
        it { should contain_service('cloudstack-management') }
        it { should_not contain_service('cloudstack-usage') }
    end
    
    context "with_usage_server" do
      let(:params) {{
        :cloudstack_install_usage => true,
      }}
  
      it { should contain_package('cloudstack-usage') }
      it { should contain_service('cloudstack-usage') }
    end
      
    context "without_cloudstack" do
      let(:params) { {
		  	:cloudstack_server => false,		  	
		  } }
		  
		  it { should compile.with_all_deps }
		  		  
		  it { should_not contain_class('cloudstack::install::cloudstack') }		  
		  it { should_not contain_class('cloudstack::config::cloudstack') }
      it { should_not contain_service('cloudstack-management') }
      it { should_not contain_service('cloudstack-usage') }
	  end
	  
	  context "without_mysql" do
      let(:params) { {		  	
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password',
		  	:mysql_server		       => false,		  	
		  } }
	  
		  it { should compile.with_all_deps }	
	  
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
		  
		  it { should_not contain_class('cloudstack::config::nfs') }
	  end
	  
    context "without_repos" do
      let(:params) {{
        :cloudstack_setup_repos  => false,
      }}
      
      it { should compile.with_all_deps } 

      it { should_not contain_class('cloudstack::install::repo') }
    end

    context "without_mgmt_package" do
      let(:params) {{
        :cloudstack_install_mgmt => false,
      }}
      
      it { should compile.with_all_deps } 

      it { should_not contain_package('cloudstack-management') }    
      it { should_not contain_service('cloudstack-management') }
    end

    context "cs_mgmt_slave" do
      let(:params) {{
        :cloudstack_master => false,
      }}
      
      it { should compile.with_all_deps } 
        
      it { should_not contain_concat('/usr/share/cloudstack-common/scripts/installer/create-sys-tpl.sh') }
      it { should_not contain_concat__fragment('create-sys-tpl-mount') }
      it { should_not contain_cloudstack__config__cloudstack__system_template('kvm') }
      it { should_not contain_exec('Install System VM templates') }
    end

    context "undefined_mysql_service" do
      let(:params) {{
        :mysql_service_name      => false,  
        :cloudstack_server_count => 2,
      }}
      
      it { should compile.with_all_deps } 
         
      it { should contain_file('/etc/mysql/conf.d/cloudstack.cnf').with_content(/max_connections=700/) }
    end
    
    context "unmanaged_nfs_root" do
      let(:params) {{
        :nfs_manage_dir          => false,
      }}
      
      it { should compile.with_all_deps } 

      it { should_not contain_file('/exports') }
    end
    
    context "version 4.3.0" do
      let(:params) {{
        :cloudstack_version => '4.3.0',
        :hypervisor_support => ['xenserver', 'kvm', 'lxc'],
      }}
      
      it { should compile.with_all_deps } 
         
      it { should contain_package('libmysql-java') }
    end
    
    context "version 4.4.0" do
      let(:params) {{
        :cloudstack_version => '4.4.0'
      }}
      
      it { should compile.with_all_deps } 

      it { should contain_file('/usr/share/cloudstack-management/setup/cs_4_4_0-schema-premium.patch') }
      it { should contain_exec('patch-cs_4_4_0-schema-premium.patch') }
    end
  end
  
  context "centos" do
    let(:facts) {  
  	  @centos_facts
  	}
  	
  	let(:pre_condition) { 
  	  "class { '::mysql::server': }
  	   class { '::nfs::server': }"
  	}
  	
    context "defaults" do 
      let(:params) { {
        :database_password     => 'password',
        :database_server_key   => 'password',
        :database_database_key => 'password',  
      } }
        
      it { should compile.with_all_deps }
    
      # Installation
      it { should contain_class('cloudstack::install') }
        it { should contain_class('cloudstack::install::cloudstack') }
          it { should contain_class('cloudstack::install::repo') }
            it { should_not contain_class('cloudstack::install::repo::apt') }
            it { should contain_class('cloudstack::install::repo::yum') }
              it { should contain_yumrepo('cloudstack').with({
                :baseurl => /http:\/\/cloudstack.apt-get.eu\/centos\/7\/4.9/ 
              })}
              
       # Configuration
       it { should contain_class('cloudstack::config') }
         it { should contain_class('cloudstack::config::nfs') }
           
         it { should contain_class('cloudstack::config::mysql') }
           
         it { should contain_class('cloudstack::config::cloudstack') }
           it { should contain_class('cloudstack::config::cloudstack::mysql') }
       
       # Service
       it { should contain_class('cloudstack::service') }
    end
  end  
end
