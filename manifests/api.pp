# Class: cloudstack::api
#
# This class manages the configuration file that Puppet uses to call the Cloudstack REST API.
#
# Parameters:
# * host (string): The host to call the API on. Default: 127.0.0.1
# * port (integer): The port to call the API on. Default: 8080
# * api_key (string): The API Key to authenticate on the API.
# * api_secret (string): The API Secret to authenticate on the API.
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class cloudstack::api (
  $api_key,
  $api_secret,
  $host = '127.0.0.1',
  $port = 8080,
) {
  # Validation
  validate_string($host, $api_key, $api_secret)

  # Config file location is currently statically configured (cloudstack_rest.rb)
  $api_auth_file = '/etc/cloudstack/api.yaml'

  # Template parameters
  $api_host = $host
  $api_port = $port

  file { $api_auth_file:
    ensure  => 'file',
    content => template('cloudstack/api.yaml.erb')
  }

  # Dependency Gems Installation
  if versioncmp($::puppetversion, '4.0.0') < 0 {
    ensure_packages(['rest-client', 'json'], {'ensure' => 'present', 'provider' => 'gem'})
  } else {
    ensure_packages(['rest-client', 'json'], {'ensure' => 'present', 'provider' => 'puppet_gem'})
  }
}
