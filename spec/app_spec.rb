

require './app.rb'
require 'rack/test'

describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App.new
  end

  it 'has a homepage' do
    get '/'
    byebug
    expect(last_response).to be_ok
  end
end
