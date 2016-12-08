#
# Cookbook Name:: hello_world
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt'
include_recipe 'build-essential'

%w(net-tools ruby-dev zlib1g-dev libsqlite3-dev libmysqlclient-dev nodejs).each do |pkg|
  package pkg
end

ruby_runtime node[:app_name] do
  provider :system
  version node[:ruby_version]
end

application node[:app_dir] do
  owner node[:user]
  group node[:user]
  git node[:app_repo]

  bundle_install do
    deployment true
    without node[:ignored_env]
  end

  rails do
    rails_env node[:app_env]
    database({
      adapter: node[:db_type],
      host: node[:db_host],
      username: node[:db_user],
      password: node[:db_pass],
      database: node[:app_name],
    })
    migrate true
  end
end
