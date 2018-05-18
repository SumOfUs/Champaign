FactoryGirl.define do
  factory :pending_action do
    data ''
    confirmed_at nil
    email 'MyString'
    token 'MyString'
  end
end
