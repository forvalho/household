ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
end

require 'capybara/rspec'
require 'capybara/dsl'
require 'rack/test'
require 'sinatra/base'
require_relative '../app'
require 'selenium/webdriver'
require 'database_cleaner/active_record'

# Load all helpers and models
Dir[File.join(__dir__, '..', 'helpers', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '..', 'models', '*.rb')].each { |file| require file }

Capybara.app = App
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods

  def app
    App
  end

  # Configure DatabaseCleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Helper method for feature specs
  def login_as(member)
    visit "/members/#{member.id}/select"
  end

  # Helper method for admin login in request specs
  def login_as_admin(admin)
    # Set the session directly for request specs
    rack_session = { admin_id: admin.id }
    env 'rack.session', rack_session
  end
end

# Usage:
#   it 'does something', js: true do ... end
# will run with Selenium and JS enabled.
