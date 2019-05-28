# spec/spec_helper.rb
require 'rack/test'
ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'app')

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    App
  end
end
