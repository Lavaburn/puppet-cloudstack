source "https://rubygems.org"

gem "ruby_dep", "1.3.1"
# 1.4.0 requires Ruby 2.2.5

group :test do
	gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.3.2'
	gem "puppetlabs_spec_helper"
	gem "metadata-json-lint"
end

group :integration_test do
	gem "beaker-rspec"
	gem "vagrant-wrapper"
end

group :development do
	gem "puppet-blacksmith"
	gem "guard-rake"
	gem "travis"
	gem "travis-lint"
end
