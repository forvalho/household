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

# Load all helpers and models
Dir[File.join(__dir__, '..', 'helpers', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '..', 'models', '*.rb')].each { |file| require file }

Capybara.app = App

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods

  def app
    App
  end

  # Clean up the test database before each run
  config.before(:suite) do
    TaskTemplate.destroy_all
    TaskCompletion.destroy_all
    Task.destroy_all
    Member.destroy_all
    Admin.destroy_all
  end

  # Clean up between tests
  config.after(:each) do
    Task.destroy_all
    Member.destroy_all
    Admin.destroy_all
    TaskCompletion.destroy_all
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
