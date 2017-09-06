FactoryGirl.define do
  factory :registered_email_address do
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end
