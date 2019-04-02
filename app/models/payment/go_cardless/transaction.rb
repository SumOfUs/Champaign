# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_transactions
#
#  id                :integer          not null, primary key
#  aasm_state        :string
#  amount            :decimal(, )
#  amount_refunded   :decimal(, )
#  charge_date       :date
#  currency          :string
#  description       :string
#  reference         :string
#  status            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  customer_id       :integer
#  go_cardless_id    :string
#  page_id           :integer
#  payment_method_id :integer
#  subscription_id   :integer
#
# Indexes
#
#  go_cardless_transaction_subscription                         (subscription_id)
#  index_payment_go_cardless_transactions_on_customer_id        (customer_id)
#  index_payment_go_cardless_transactions_on_page_id            (page_id)
#  index_payment_go_cardless_transactions_on_payment_method_id  (payment_method_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => payment_go_cardless_customers.id)
#  fk_rails_...  (page_id => pages.id)
#  fk_rails_...  (payment_method_id => payment_go_cardless_payment_methods.id)
#

class Payment::GoCardless::Transaction < ApplicationRecord
  include AASM

  belongs_to :page
  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'
  belongs_to :subscription, class_name:   'Payment::GoCardless::Subscription'

  after_create :increment_funding_counter

  validates :go_cardless_id, presence: true, allow_blank: false

  scope :one_off, -> { where(subscription_id: nil) }

  ACTION_FROM_STATE = {
    submitted: :submit,
    confirmed: :confirm,
    cancelled: :cancel,
    failed: :fail,
    charged_back: :charge_back,
    paid_out: :pay_out
  }.freeze

  aasm do
    state :created, initial: true
    state :submitted
    state :confirmed
    state :paid_out
    state :cancelled
    state :failed
    state :charged_back

    event :run_submit do
      transitions from: :created, to: :submitted
    end

    event :run_confirm do
      transitions from: %i[created submitted], to: :confirmed
    end

    event :run_payout do
      transitions from: %i[created submitted confirmed], to: :paid_out
    end

    event :run_cancel do
      transitions to: :cancelled
    end

    event :run_fail do
      transitions to: :failed, after: :publish_failed_subscription_charge
    end

    event :run_charge_back do
      transitions to: :charged_back
    end
  end

  def publish_failed_subscription_charge
    return if subscription.blank?

    ChampaignQueue.push({
      type: 'subscription-payment',
      params: {
        created_at: created_at.strftime('%Y-%m-%d %H:%M:%S'),
        recurring_id: subscription.go_cardless_id,
        success: 0,
        status: 'failed',
        trans_id: go_cardless_id
      }
    },
                        { group_id: "gocardless-subscription:#{id}" })
  end

  def increment_funding_counter
    FundingCounter.update(page: page, currency: currency, amount: amount)
  end
end
