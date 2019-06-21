require_relative '../spec_helper'
require_relative '../helpers'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe 'login', type: :feature do
  it 'logs in' do
    log_in
    expect(page).to have_css '.agregar'
  end

  it 'logs out' do
    log_in
    visit '/crear'
    click_link 'Cerrar', match: :first
    expect(page).to have_content 'Iniciar Session'
  end

  it 'doesnt allow incorrect password' do
    visit '/'
    fill_in 'user', with: 'Wrong'
    fill_in 'pass', with: 'wrong'
    find('#entrar').click
    expect(page).to have_content 'contrasena incorecta'
  end
end
