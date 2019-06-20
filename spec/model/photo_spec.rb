require_relative '../spec_helper'


RSpec.describe Photo,type: :model do

  it 'has a valid factory' do
    photo = FactoryBot.create :photo
    expect(photo).to be_valid
  end

  it 'Subtracts Days' do
    photo = FactoryBot.create :photo,days: 5
    Photo.subtract_day!
    photo.reload
    expect(photo.days).to eq 4
  end

  it 'deactivtes if days is 0' do
    photo = FactoryBot.create :photo,days: 1
    Photo.subtract_day!
    photo.reload
    expect(photo.active).to eq false
  end

end
