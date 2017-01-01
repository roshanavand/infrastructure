# # encoding: utf-8

# Inspec test for recipe hello_world::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe package 'httpd' do
  it { should be_installed }
end

describe service 'httpd' do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe directory(node[:app_dir]) do
  its('users') { should cmp node[:user] }
end

describe gem('passenger') do
  it { should be_installed }
end

describe command 'curl localhost' do
  its('stdout') { should match /login/ }
end
