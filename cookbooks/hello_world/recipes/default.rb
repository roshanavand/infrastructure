#
# Cookbook Name:: hello_world
# Recipe:: default
#
# Copyright (c) 2016 Mos Roshanavand, All Rights Reserved.

template '/etc/yum.repos.d/epel.repo' do
  source 'epel.repo'
end

yum_repository 'epel' do
  enabled true
  action :makecache
end

package 'ruby20-libs' do
  action :remove
end

%w(mysql mysql-devel mysql-libs nodejs ruby23 ruby23-devel ruby23-libs
  gcc bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel
  libcurl-devel gdbm-devel ncurses-devel gcc-c++ httpd httpd-devel).each do |pkg|
  package pkg
end

application node[:app_dir] do
  owner node[:user]
  group node[:user]
  git node[:app_repo]

  ruby_gem 'bundler'
  ruby_gem 'passenger' do
    version '5.1.1'
  end

  bundle_install do
    user node[:user]
    deployment true
    without node[:ignored_env]
  end

  rails do
    rails_env node[:app_env]
    secrets_mode :yaml
    secret_token ENV['HELLO_WORLD_SECRET_KEY_BASE']
    database({
      adapter: node[:db_type],
      host: ENV['HELLO_WORLD_DATABASE_URL'],
      username: ENV['HELLO_WORLD_DATABASE_USER'],
      password: ENV['HELLO_WORLD_DATABASE_PASSWORD'],
      database: ENV['HELLO_WORLD_DATABASE_NAME'],
    })
    migrate true
  end

  execute 'install_passenger_module' do
    command 'passenger-install-apache2-module --auto'
    creates '/usr/local/share/ruby/gems/2.3/gems/passenger-5.1.1/buildout/apache2/mod_passenger.so'
  end

  template '/etc/httpd/conf.d/passenger.conf' do
    source 'passenger.conf'
  end

  template "/etc/httpd/conf.d/#{node[:app_name]}.conf" do
    source 'apache_site.conf.erb'
  end

  service 'httpd' do
    action [:enable, :start]
  end
end
