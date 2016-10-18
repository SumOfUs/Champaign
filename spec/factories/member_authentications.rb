# frozen_string_literal: true
FactoryGirl.define do
  factory :member_authentication do
    member
    password 'password'
    password_confirmation 'password'
    facebook_uid { Faker::Number.number(8) }
    facebook_token { Digest::SHA256.hexdigest(Faker::Lorem.characters) }
    facebook_token_expiry { Faker::Date.forward }
    confirmed_at nil
  end
end
