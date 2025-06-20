require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
end

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'capybara/rspec'
require 'capybara/dsl'
require 'database_cleaner/active_record'

# Load the Sinatra application
require File.expand_path '../app.rb', __dir__

# Configure RSpec
RSpec.configure do |config|
  # Include Rack::Test methods for request specs
  config.include Rack::Test::Methods

  # Include Capybara DSL for feature specs
  config.include Capybara::DSL

  # Define the app for Rack::Test
  def app
    Sinatra::Application
  end

  # Configure Capybara
  Capybara.app = Sinatra::Application

  # Configure DatabaseCleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
