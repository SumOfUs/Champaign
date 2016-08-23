# frozen_string_literal: true
FactoryGirl.define do
  factory :donation_band do
    name { Faker::Internet.slug }
    amounts { [rand(20), rand(300), rand(300), rand(300), rand(300)].map{|fl| fl.to_i * 100}.sort }
  end
end
