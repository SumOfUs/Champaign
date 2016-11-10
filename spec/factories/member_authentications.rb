# frozen_string_literal: true
# == Schema Information
#
# Table name: member_authentications
#
#  id                     :integer          not null, primary key
#  member_id              :integer
#  password_digest        :string           not null
#  facebook_uid           :string
#  facebook_token         :string
#  facebook_token_expiry  :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  token                  :string
#  confirmed_at           :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#

FactoryGirl.define do
  factory :member_authentication do
    member
    password 'password'
    password_confirmation 'password'
    facebook_uid { Faker::Number.number(8) }
    facebook_token { Digest::SHA256.hexdigest(Faker::Lorem.characters) }
    facebook_token_expiry { Faker::Date.forward }
    confirmed_at nil
    trait :confirmed do
      confirmed_at Time.now
    end

    trait :with_reset_password_token do
      reset_password_token '123'
      reset_password_sent_at Time.now
    end
  end
end
