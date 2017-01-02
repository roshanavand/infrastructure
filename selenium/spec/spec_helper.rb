require 'rubygems'
require 'rspec'
require 'capybara/rspec'
require 'selenium-webdriver'

RSpec.configure do |config|
  config.before do
    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end
    Capybara.default_driver = :chrome
    Capybara.javascript_driver = :chrome
    Capybara.default_max_wait_time = 5
  end

  config.formatter = :documentation
  config.include Capybara::DSL
end

WEBSITE_URL = 'ELASTIC LOADBALANCER URL HERE'
