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

class Payment::Braintree::Transaction < ApplicationRecord
  attr_accessor :refund_synced, :newrecord

  belongs_to :page
  belongs_to :payment_method, class_name: 'Payment::Braintree::PaymentMethod'
  belongs_to :customer,       class_name: 'Payment::Braintree::Customer', primary_key: 'customer_id'
  belongs_to :subscription,   class_name: 'Payment::Braintree::Subscription'
  enum status: %i[success failure]

  scope :one_off,  -> { where(subscription_id: nil) }
  scope :refunded, -> { where(refund: true) }

  before_save :set_refund_and_creation_state
  after_save  :update_funding_counter

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

  # def increment_funding_counter
  #   FundingCounter.update(page: page, currency: currency, amount: amount)
  # end

  def set_refund_and_creation_state
    self.newrecord     = new_record?
    self.refund_synced = refund_was
    true
  end

  def update_funding_counter
    return true if newrecord && status != 'success'
    return true if refund_synced

    FundingCounter.update(page: page, currency: currency, amount: amount, refund: refund)
  end
end
