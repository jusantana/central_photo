
require_relative '../spec_helper'


RSpec.describe 'Sinatra App' do

  it 'has a homepage' do
    get '/'
    expect(last_response).to be_ok
  end
end
