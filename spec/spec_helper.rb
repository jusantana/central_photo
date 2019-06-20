# spec/spec_helper.rb
require 'rack/test'
require 'capybara/rspec'
require 'simplecov'
require 'factory_bot'
require 'database_cleaner'
SimpleCov.start
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov


ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'app')

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    App
  end
  config.include Capybara
  config.before(:suite) do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.clean_with(:truncation)
 end
end
Capybara.app = App
# Add Factory factory_bot
FactoryBot.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
FactoryBot.find_definitions
