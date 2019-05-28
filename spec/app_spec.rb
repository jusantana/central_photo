
require 'rspec'
require './app.rb'
require 'rack/test'

RSpec.describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App.new
  end

  it 'has a homepage' do
    get '/'
    expect(last_response).to be_ok
  end
end
