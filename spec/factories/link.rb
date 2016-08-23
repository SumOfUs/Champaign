# frozen_string_literal: true
FactoryGirl.define do
  factory :link do
    title { Faker::Company.bs }
    url { Faker::Internet.url }
  end
end
