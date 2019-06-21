
require_relative '../spec_helper'


RSpec.describe 'Sinatra App',type: :feature do

  it 'has a homepage' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'logins' do
    post '/', {'user' => ENV['USERNAME'],'pass' => ENV['PASS']}
    expect(last_response.location).to eq('http://example.org/crear')
  end

  it 'redirects home if not loged in' do
    get '/envivo'
    expect(last_response.location).to eq('http://example.org/')
  end

  it 'has a display page' do
    get '/display'
    expect(last_response).to be_ok
  end

  it 'has display/:did page' do
    FactoryBot.create(:display, display_id: 1)
    get '/display/1'
    expect(last_response).to be_ok
  end

end
