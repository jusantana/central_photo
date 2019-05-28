
require_relative '../spec_helper'


RSpec.describe 'Sinatra App' do

  it 'has a homepage' do
    get '/'
    expect(last_response).to be_ok
  end
  it 'logins' do
    post '/', {'user' => ENV['USERNAME'],'pass' => ENV['PASS']}
    expect(last_response).to be_ok
  end
  it 'has crear' do
    get '/crear'
    expect(last_response).to be_ok
  end
end
