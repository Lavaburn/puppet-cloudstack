require 'spec_helper'

describe 'cloudstack::agent' do
  let(:facts) { {
  	:osfamily 			=> 'debian',
  	:operatingsystem 	=> 'Ubuntu',
  	:lsbdistid			=> 'Ubuntu',
  	:lsbdistcodename 	=> 'saucy',
  	:concat_basedir 	=> '/tmp'
  } }

  Puppet::Util::Log.level = :warning
  Puppet::Util::Log.newdestination(:console)
  
  context "with_defaults" do
  
  
  
	  it { should contain_package('cloudstack-agent') }  	  
  end
end
