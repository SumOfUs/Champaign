# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_customers
#
#  id             :integer          not null, primary key
#  go_cardless_id :string
#  email          :string
#  given_name     :string
#  family_name    :string
#  postal_code    :string
#  country_code   :string
#  language       :string
#  member_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :payment_go_cardless_customer, class: 'Payment::GoCardless::Customer' do
    go_cardless_id { "CU#{Faker::Number.number(6)}" }
    email { Faker::Internet.email }
    country_code { 'GB' }
    language { 'en' }
  end
end
