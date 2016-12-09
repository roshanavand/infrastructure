def random_password(length)
  require 'securerandom'
  SecureRandom.base64(length)
end

# App attributes
default[:user] = 'ubuntu'
default[:ruby_version] = '2.3'
default[:app_name] = 'hello_world'
default[:app_dir] = "/opt/#{default[:app_name]}"
default[:app_repo] = 'https://github.com/roshanavand/hello_world.git'
default[:app_env] = 'production'
default[:app_secret_token] = random_password(128)
default[:ignored_env] = %w(development test)

# Database attributes
default[:db_user] = 'user'
default[:db_pass] = 'password'
default[:db_host] = 'dbhost'
default[:db_type] = 'mysql2'
default[:db_name] = default[:app_name]

# Passenger attributes
default[:nginx][:passenger][:root] = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
default[:nginx][:passenger][:ruby] = '/usr/bin/ruby'
default[:nginx][:passenger][:nodejs] = '/usr/bin/nodejs'
default[:passenger_repo_uri] = 'https://oss-binaries.phusionpassenger.com/apt/passenger'
default[:passenger_repo_key] = '561F9B9CAC40B2F7'
default[:passenger_repo_keyserver] = 'keyserver.ubuntu.com'
