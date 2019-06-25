require_relative '../spec_helper'

RSpec.describe 'Display', type: :feature do
  it 'display has no layout' do
    visit '/display'
    expect(page).to_not have_content 'Central'
  end

  it 'display with id has no layout' do
    FactoryBot.create(:display, display_id: 1)
    visit '/display/1'
    expect(page).to_not have_content 'Central'
  end
end
