# frozen_string_literal: true
FactoryGirl.define do
  sequence(:email) { |n| "person#{n}@gmail.com" }
  sequence(:slug)  { |n| "petition-#{n}" }
  sequence(:page_display_order) { |n| n }
  sequence(:actionkit_id) { |n| n }
  sequence(:actionkit_uri) { |n| "/rest/v1/tag/#{n}/" }

  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    admin false
  end

  factory :admin, class: :user do
    email
    password { Faker::Internet.password }
    admin true
  end

  factory :tag do
    sequence(:name) { |n| "#{['+', '@', '*'].sample}#{Faker::Commerce.color}#{n}" }
    actionkit_uri
  end
end
