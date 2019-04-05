# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_customers
#
#  id             :integer          not null, primary key
#  country_code   :string
#  email          :string
#  family_name    :string
#  given_name     :string
#  language       :string
#  postal_code    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  go_cardless_id :string
#  member_id      :integer
#
# Indexes
#
#  index_payment_go_cardless_customers_on_member_id  (member_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#

FactoryBot.define do
  factory :payment_go_cardless_customer, class: 'Payment::GoCardless::Customer' do
    go_cardless_id { "CU#{Faker::Number.number(6)}" }
    email { Faker::Internet.email }
    country_code { 'GB' }
    language { 'en' }
  end
end
