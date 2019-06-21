module Helpers
  def log_in
    visit '/'
    fill_in 'user', with: ENV['USERNAME']
    fill_in 'pass', with: ENV['PASS']
    find('#entrar').click
  end

  def create_displays
    (1..6).each do |i|
      FactoryBot.create(:display, display_id: i)
    end
  end
end
