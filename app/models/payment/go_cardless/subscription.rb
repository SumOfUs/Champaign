# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_go_cardless_subscriptions
#
#  id                :integer          not null, primary key
#  go_cardless_id    :string
#  amount            :decimal(, )
#  currency          :string
#  status            :integer
#  name              :string
#  payment_reference :string
#  page_id           :integer
#  action_id         :integer
#  payment_method_id :integer
#  customer_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  aasm_state        :string
#

class Payment::GoCardless::Subscription < ActiveRecord::Base
  class Charge
    attr_reader :subscription, :event

    delegate :page_id, :amount, :currency, :payment_method_id, :customer_id, to: :subscription

    def initialize(subscription, event = {})
      @event = event
      @subscription = subscription
    end

    def call
      Payment::GoCardless.write_transaction(
        uuid: event['links']['payment'],
        amount: amount,
        currency: currency,
        charge_date: event['created_at'],
        page_id: page_id,
        customer_id: customer_id,
        payment_method_id: payment_method_id,
        subscription: subscription
      )

      ChampaignQueue.push(
        type: 'subscription-payment',
        params: {
          recurring_id: @subscription.go_cardless_id
        }
      )
    end
  end
end

class Payment::GoCardless::Subscription < ActiveRecord::Base
  include AASM

  validates :go_cardless_id, presence: true, allow_blank: false

  belongs_to :page
  belongs_to :action
  belongs_to :customer,       class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'
  has_many   :transactions,   class_name: 'Payment::GoCardless::Transaction', foreign_key: :subscription_id

  scope :active, -> { where(cancelled_at: nil) }

  ACTION_FROM_STATE = {
    created:                    :create,
    cancelled:                  :cancel,
    payment_created:            :payment_create,
    customer_approval_granted:  :approve,
    customer_approval_denied:   :deny
  }.freeze

  aasm do
    state :pending, initial: true
    state :created
    state :customer_approval_denied
    state :active
    state :finished
    state :cancelled

    event :run_create do
      transitions from: [:pending], to: :created
    end

    event :run_approve do
      transitions from: [:pending, :created], to: :active
    end

    event :run_cancel do
      transitions to: :cancelled
    end

    event :run_finish do
      transitions to: :finished
    end

    event :run_deny do
      transitions to: :customer_approval_denied
    end

    event :run_payment_create do
      transitions to: :active, after: Payment::GoCardless::Subscription::Charge
    end
  end

  def cancel_on_ak(reason)
    # reason can be "user", "admin", "processor", "failure", "expired"
    ChampaignQueue.push(type: 'cancel_subscription',
                        params: {
                          recurring_id: go_cardless_id,
                          canceled_by: reason
                        })
  end
end
