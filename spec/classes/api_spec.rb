require 'spec_helper'

describe 'cloudstack::api' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "ubuntu" do
    let(:facts) {
        @ubuntu_facts
    }
    
	  context "defaults" do	  
      let(:params) {{
        :api_key    => 'password',
        :api_secret => 'password'
      }}
      
		  it { should compile.with_all_deps }

      it { should contain_file('/etc/cloudstack/api.yaml') }
		  it { should contain_package('json') }
      it { should contain_package('rest-client') }
    end
  end
  
  context "centos" do
    let(:facts) {  
      @centos_facts
    }
    
    context "defaults" do   
      let(:params) {{
        :api_key    => 'password',
        :api_secret => 'password'
      }}
      
      it { should compile.with_all_deps }

      it { should contain_file('/etc/cloudstack/api.yaml') }
      it { should contain_package('json') }
      it { should contain_package('rest-client') }
    end
  end  
end
