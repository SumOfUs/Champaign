# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_braintree_transactions
#
#  id                      :integer          not null, primary key
#  transaction_id          :string
#  transaction_type        :string
#  transaction_created_at  :datetime
#  payment_method_token    :string
#  customer_id             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  merchant_account_id     :string
#  currency                :string
#  page_id                 :integer
#  payment_instrument_type :string
#  status                  :integer
#  amount                  :decimal(10, 2)
#  processor_response_code :string
#  payment_method_id       :integer
#  subscription_id         :integer
#

FactoryBot.define do
  factory :payment_braintree_transaction, class: 'Payment::Braintree::Transaction' do
    transaction_id { "t#{Faker::Number.number(4)}" }
    transaction_type { 'credit_card' }
    status { 0 }
    amount { 12.34 }
    transaction_created_at { '2015-11-17 16:46:19' }
    payment_method_id { "asdf#{Faker::Number.number(10)}" }
    customer_id { Faker::Number.number(4) }
    association :page, factory: :page

    trait :with_subscription do
      association :subscription, factory: :payment_braintree_subscription
    end
  end
end
