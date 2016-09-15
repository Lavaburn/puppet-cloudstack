require 'spec_helper'

describe 'cloudstack::cloudmonkey' do
  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "ubuntu" do
    let(:facts) {
        @ubuntu_facts
    }

	  context "install_python" do	  
      let(:params) {{
        :setup_python => true,
      }}
                
		  it { should compile.with_all_deps }

      it { should contain_class('python') }
		  it { should contain_python__pip('cloudmonkey') }
    end
  end
  
  context "centos" do
    let(:facts) {  
      @centos_facts
    }
    
    context "install_python" do    
      let(:params) {{
        :setup_python => true,
      }}
      
      it { should compile.with_all_deps }

      it { should contain_class('python') }
      it { should contain_python__pip('cloudmonkey') }
    end
  end  
end
