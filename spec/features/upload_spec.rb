require_relative '../spec_helper'


RSpec.describe 'Upload',type: :feature do
  include Rack::Test::Methods
  # => include ActionDispatch::TestProcess

  it 'Create a valid Photo object to specific screen' do
    #file = fixture_file_upload('./pics/pic.png','image/png')
    #post '/crear', { file: file, display: 1}
    #expect(last_response).to be_ok
  end
  it 'logins' do
    post '/', {'user' => ENV['USERNAME'],'pass' => ENV['PASS']}
    expect(last_response.location).to eq('http://example.org/crear')
  end

end
