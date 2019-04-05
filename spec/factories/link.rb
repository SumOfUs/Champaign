# frozen_string_literal: true

FactoryBot.define do
  factory :link do
    title { Faker::Company.bs }
    url { Faker::Internet.url }
  end
end
