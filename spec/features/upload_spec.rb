require_relative '../spec_helper'
require_relative '../helpers'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe 'Upload',type: :feature do


  it 'Create a valid Photo object to specific screen' do
    create_displays
    log_in
    visit '/crear'
    page.attach_file('files', Dir.pwd + '/spec/pics/pic.png')
    fill_in 'days', with: 5
    page.select '1', from: 'display'
    page.click_button 'entrar'
    expect(page).to have_css '.photo'
  end
  
  it 'logins' do
    post '/', {'user' => ENV['USERNAME'],'pass' => ENV['PASS']}
    expect(last_response.location).to eq('http://example.org/crear')
  end

end
