# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_braintree_transactions
#
#  id                      :integer          not null, primary key
#  amount                  :decimal(10, 2)
#  amount_refunded         :decimal(8, 2)
#  currency                :string
#  payment_instrument_type :string
#  payment_method_token    :string
#  processor_response_code :string
#  refund                  :boolean          default(FALSE)
#  refunded_at             :datetime
#  status                  :integer
#  transaction_created_at  :datetime
#  transaction_type        :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  customer_id             :string
#  merchant_account_id     :string
#  page_id                 :integer
#  payment_method_id       :integer
#  refund_transaction_id   :string
#  subscription_id         :integer
#  transaction_id          :string
#
# Indexes
#
#  braintree_payment_method_index                   (payment_method_id)
#  braintree_transaction_subscription               (subscription_id)
#  index_payment_braintree_transactions_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
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
