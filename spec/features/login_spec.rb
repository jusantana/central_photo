

require_relative '../spec_helper'


RSpec.describe 'login',type: :feature do

  it 'logs in' do
    visit '/'
    fill_in 'user', with: ENV['USERNAME']
    fill_in 'pass', with: ENV['PASS']
    find('#entrar').click

    expect(page).to have_css '.agregar'
  end

end
