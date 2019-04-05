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

class Payment::Braintree::Subscription < ApplicationRecord
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
    ChampaignQueue.push(
      { type: 'cancel_subscription',
        params: {
          recurring_id: subscription_id,
          canceled_by: reason
        } },
      { group_id: "braintree-subscription:#{id}" }
    )
  end

  def publish_amount_update
    ChampaignQueue.push(
      { type: 'recurring_payment_update',
        params: {
          recurring_id: subscription_id,
          amount: amount.to_s
        } },
      { group_id: "braintree-subscription:#{id}" }
    )
  end
end
