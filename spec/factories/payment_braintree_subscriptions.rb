# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_subscriptions
#
#  id                  :integer          not null, primary key
#  subscription_id     :string
#  merchant_account_id :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  page_id             :integer
#  amount              :decimal(10, 2)
#  currency            :string
#  action_id           :integer
#  cancelled_at        :datetime
#

FactoryGirl.define do
  factory :payment_braintree_subscription, class: 'Payment::Braintree::Subscription' do
    subscription_id { "s#{Faker::Number.number(4)}" }
    amount 79.41
    currency 'GBP'
    merchant_account_id 'GBP'
    customer_id Faker::Number.number(4)
    billing_day_of_month Faker::Number.between(1, 31)
  end
end
