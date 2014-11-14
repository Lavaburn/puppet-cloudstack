# Required gems
require 'rubygems'
require 'bundler/setup'
require 'hiera'

# Gems: Rake tasks
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These gems aren't always present
begin
	#On Travis with --without development
	require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end


# Directories that don't need to be checked (Lint/Syntax)
exclude_paths = [
	"spec/**/*",
]


# Puppet Lint config
	# https://github.com/garethr/puppet-module-skeleton/pull/31
	Rake::Task[:lint].clear # TODO - THIS REMOVE THE LINT CHECK !!!
 
PuppetLint.configuration.relative = true
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.with_context = true
#PuppetLint.configuration.fix = true

PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"

#config.disable_checks = ['80chars', 'class_parameter_defaults', 'class_inherits_from_params_class']

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths


# Extra Tasks
desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
	t.pattern = 'spec/acceptance'
end

desc "Run syntax, lint, and spec tests."
task :test => [
	:syntax,
	:lint,
	:metadata,
	:spec,
]