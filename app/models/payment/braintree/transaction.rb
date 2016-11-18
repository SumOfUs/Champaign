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

class Payment::Braintree::Transaction < ActiveRecord::Base
  belongs_to :page
  belongs_to :payment_method, class_name: 'Payment::Braintree::PaymentMethod'
  belongs_to :customer,       class_name: 'Payment::Braintree::Customer', primary_key: 'customer_id'
  belongs_to :subscription,   class_name: 'Payment::Braintree::Subscription'
  enum status: [:success, :failure]

  scope :one_off, -> { where(subscription_id: nil) }

  def publish_subscription_charge
    ChampaignQueue.push({
      type: 'subscription-payment',
      params: {
        recurring_id: self.subscription.try(:action).form_data['subscription_id'],
        success: self.status == 'success' ? 1 : 0
      }
    }, { delay: 120 })
  end
end
