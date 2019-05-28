# spec/spec_helper.rb
require 'rack/test'
require 'capybara/rspec'
ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'app')

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    App
  end
  config.include Capybara
end
Capybara.app = Sinatra::Application
