#
# Cookbook Name:: hello_world
# Recipe:: default
#
# Copyright (c) 2016 Mos Roshanavand, All Rights Reserved.

include_recipe 'apt'
include_recipe 'build-essential'

apt_repository 'phusionpassenger' do
  uri node[:passenger_repo_uri]
  distribution 'xenial'
  components ['main']
  key node[:passenger_repo_key]
  keyserver node[:passenger_repo_keyserver]
  action :add
end

%w(net-tools ruby-dev zlib1g-dev libsqlite3-dev libmysqlclient-dev nodejs).each do |pkg|
  package pkg
end

application node[:app_dir] do
  owner node[:user]
  group node[:user]
  ruby node[:ruby_version]
  git node[:app_repo]

  bundle_install do
    user node[:user]
    deployment true
    without node[:ignored_env]
  end

  rails do
    rails_env node[:app_env]
    secrets_mode :yaml
    secret_token node[:app_secret_token]
    database({
      adapter: node[:db_type],
      host: node[:db_host],
      username: node[:db_user],
      password: node[:db_pass],
      database: node[:db_name],
    })
    migrate true
  end
end

include_recipe 'chef_nginx::default'
include_recipe 'chef_nginx::passenger'

nginx_site 'default' do
  action :disable
end

nginx_site node[:app_name] do
  template 'hello_world.cnf.erb'
  notifies :restart, 'service[nginx]'
end
