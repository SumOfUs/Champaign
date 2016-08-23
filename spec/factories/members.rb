# frozen_string_literal: true
FactoryGirl.define do
  factory :member do
    email { Faker::Internet.email }
  end
end
