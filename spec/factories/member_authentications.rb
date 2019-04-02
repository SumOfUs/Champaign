# frozen_string_literal: true

# == Schema Information
#
# Table name: member_authentications
#
#  id                     :integer          not null, primary key
#  confirmed_at           :datetime
#  facebook_token         :string
#  facebook_token_expiry  :datetime
#  facebook_uid           :string
#  password_digest        :string           not null
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  token                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  member_id              :integer
#
# Indexes
#
#  index_member_authentications_on_facebook_uid          (facebook_uid)
#  index_member_authentications_on_member_id             (member_id)
#  index_member_authentications_on_reset_password_token  (reset_password_token)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#

FactoryBot.define do
  factory :member_authentication do
    member
    password { 'password' }
    password_confirmation { 'password' }
    facebook_uid { Faker::Number.number(8) }
    facebook_token { Digest::SHA256.hexdigest(Faker::Lorem.characters) }
    facebook_token_expiry { Faker::Date.forward }
    confirmed_at { nil }
    trait :confirmed do
      confirmed_at { Time.now }
    end

    trait :with_reset_password_token do
      reset_password_token { '123' }
      reset_password_sent_at { Time.now }
    end
  end
end
