FactoryBot.define do
  factory :display do
    display_id {}
    active { true }
    last_call { Time.now }
  end
end
