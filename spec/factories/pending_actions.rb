FactoryGirl.define do
  factory :pending_action do
    data {}
    confirmed_at nil
    email 'bar@example.com'
    token '1234'
  end
end
