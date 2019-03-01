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

class Payment::Braintree::Transaction < ApplicationRecord
  belongs_to :page
  belongs_to :payment_method, class_name: 'Payment::Braintree::PaymentMethod'
  belongs_to :customer,       class_name: 'Payment::Braintree::Customer', primary_key: 'customer_id'
  belongs_to :subscription,   class_name: 'Payment::Braintree::Subscription'
  enum status: %i[success failure]

  scope :one_off, -> { where(subscription_id: nil) }

  after_create :increment_funding_counter

  def publish_subscription_charge
    ChampaignQueue.push({
      type: 'subscription-payment',
      params: {
        created_at: created_at.strftime('%Y-%m-%d %H:%M:%S'),
        recurring_id: subscription.try(:action).form_data['subscription_id'],
        success: status == 'success' ? 1 : 0,
        status: status == 'success' ? 'completed' : 'failed',
        amount: amount.to_s,
        trans_id: transaction_id
      }
    },
                        { group_id: "braintree-subscription:#{subscription.id}" })
  end

  def increment_funding_counter
    return unless status == 'success'

    FundingCounter.update(page: page, currency: currency, amount: amount)
  end
end
