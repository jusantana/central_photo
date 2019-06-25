require_relative '../spec_helper'

RSpec.describe 'Display', type: :feature do
  it 'display has no layout' do
    visit '/display'
    expect(page).to_not have_content 'Central'
  end

  it 'display with id has no layout' do
    # skip
    display = FactoryBot.create(:display, display_id: 1, id: 100)
    visit '/display/1'
    expect(page).to_not have_content 'Central'
  end
end
