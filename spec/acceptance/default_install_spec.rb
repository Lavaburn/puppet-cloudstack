require 'spec_helper_acceptance'

describe 'cloudstack class' do
	describe 'running puppet code' do
    	it 'should work with no errors' do
      		pp = <<-EOS
      		  class { '::mysql::server': }
            class { '::nfs::server': }
            class { '::wget': }
            class { '::apt': }
        		class { 'cloudstack': }
      		EOS

      		# Run it twice and test for idempotency
      		apply_manifest(pp, :catch_failures => true)
      		
      		expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      	end
    end
end