FactoryGirl.define do
  factory :action_user do
    email { Faker::Internet.email }
  end
end
