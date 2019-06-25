require_relative '../spec_helper'
require_relative '../helpers'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe 'Upload', type: :feature do
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

  it 'activates photos' do
    log_in
    photo = FactoryBot.create(:photo, display_id: 1, active: false)
    visit '/envivo'
    select 'Activar', from: "[#{photo.id}][action]"
    click_button 'actualizar'
    photo.reload
    expect(photo.active).to eq true
  end

  it 'deactivates photos' do
    log_in
    photo = FactoryBot.create(:photo, display_id: 1, active: true)
    visit '/envivo'
    select 'Desactivar', from: "[#{photo.id}][action]"
    click_button 'actualizar'
    photo.reload
    expect(photo.active).to eq false
  end

  it 'deletes photos' do
    log_in
    visit '/envivo'
    photo = Photo.find_by display_id: 1
    select 'Borrar', from: "[#{photo.id}][action]"
    click_button 'actualizar'
    expect { photo.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
