# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_braintree_subscriptions
#
#  id                   :integer          not null, primary key
#  amount               :decimal(10, 2)
#  billing_day_of_month :integer
#  cancelled_at         :datetime
#  currency             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  action_id            :integer
#  customer_id          :string
#  merchant_account_id  :string
#  page_id              :integer
#  payment_method_id    :integer
#  subscription_id      :string
#
# Indexes
#
#  index_payment_braintree_subscriptions_on_action_id        (action_id)
#  index_payment_braintree_subscriptions_on_page_id          (page_id)
#  index_payment_braintree_subscriptions_on_subscription_id  (subscription_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

FactoryBot.define do
  factory :payment_braintree_subscription, class: 'Payment::Braintree::Subscription' do
    subscription_id { "s#{Faker::Number.number(4)}" }
    amount { 79.41 }
    currency { 'GBP' }
    merchant_account_id { 'GBP' }
    customer_id { Faker::Number.number(4) }
    billing_day_of_month { Faker::Number.between(1, 31) }
  end
end
