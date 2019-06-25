require_relative '../spec_helper'

RSpec.describe Display, type: :model do
  it 'has a valid factory' do
    display = FactoryBot.create :display
    expect(display).to be_valid
  end

  it 'sets last call' do
    display = FactoryBot.create(:display, display_id: 10)
    display.update_status
    display.reload
    expect(display.last_call).to be > Time.now - 5 # Subtracts five seconds from time now
  end
end
