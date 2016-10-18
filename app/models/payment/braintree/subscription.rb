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

class Payment::Braintree::Subscription < ActiveRecord::Base
  belongs_to :page
  belongs_to :action
  belongs_to :customer, class_name: 'Payment::Braintree::Customer',
                        primary_key: 'customer_id',
                        foreign_key: 'customer_id'
  belongs_to :payment_method, class_name: 'Payment::Braintree::PaymentMethod'
  has_many   :transactions,   class_name: 'Payment::Braintree::Transaction',
                              foreign_key: :subscription_id

  scope :active, -> { where(cancelled_at: nil) }

  def publish_cancellation(reason)
    # reason can be "user", "admin", "processor", "failure", "expired"
    ChampaignQueue.push(type: 'cancel_subscription',
                        params: {
                          recurring_id: subscription_id,
                          canceled_by: reason
                        })
  end
end
