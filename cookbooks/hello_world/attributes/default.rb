# App attributes
default[:user] = 'ec2-user'
default[:app_name] = 'hello_world'
default[:app_dir] = "/opt/#{default[:app_name]}"
default[:app_repo] = 'https://github.com/roshanavand/hello_world.git'
default[:app_env] = 'production'
default[:ignored_env] = %w(development test)
default[:db_type] = 'mysql2'
