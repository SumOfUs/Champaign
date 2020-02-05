# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_transactions
#
#  id                    :integer          not null, primary key
#  aasm_state            :string
#  amount                :decimal(, )
#  amount_refunded       :decimal(, )
#  charge_date           :date
#  currency              :string
#  description           :string
#  reference             :string
#  refund                :boolean          default(FALSE)
#  refunded_at           :datetime
#  status                :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  ak_donation_action_id :string
#  ak_order_id           :string
#  ak_transaction_id     :string
#  ak_user_id            :string
#  customer_id           :integer
#  go_cardless_id        :string
#  page_id               :integer
#  payment_method_id     :integer
#  refund_transaction_id :string
#  subscription_id       :integer
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
  attr_accessor :refund_synced, :newrecord
  include AASM

  belongs_to :page
  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'
  belongs_to :subscription, class_name:   'Payment::GoCardless::Subscription'

  before_save :set_refund_and_creation_state
  after_save  :update_funding_counter

  validates :go_cardless_id, presence: true, allow_blank: false

  scope :one_off, -> { where(subscription_id: nil) }

  ACTION_FROM_STATE = {
    submitted: :submit,
    confirmed: :confirm,
    cancelled: :cancel,
    failed: :fail,
    charged_back: :charge_back,
    paid_out: :pay_out,
    refunded: :refunded
  }.freeze

  aasm do # rubocop:disable Metrics/BlockLength
    state :created, initial: true
    state :submitted
    state :confirmed
    state :paid_out
    state :cancelled
    state :failed
    state :charged_back
    state :refunded

    event :run_submit do
      transitions from: :created, to: :submitted, after: :publish_transaction_status_change
    end

    event :run_confirm do
      transitions from: %i[created submitted], to: :confirmed, after: :publish_transaction_status_change
    end

    # TODO: remove the method if it not used in any case post testing
    event :run_payout do
      transitions from: %i[created submitted confirmed], to: :paid_out, after: :publish_transaction_status_change
    end

    event :run_pay_out do
      transitions from: %i[created submitted confirmed], to: :paid_out, after: :publish_transaction_status_change
    end

    event :run_cancel do
      transitions to: :cancelled, after: :publish_transaction_status_change
    end

    event :run_fail do
      transitions to: :failed, after: :publish_failed_subscription_charge
    end

    event :run_charge_back do
      transitions to: :charged_back, after: :publish_transaction_status_change
    end

    event :run_refund do
      transitions to: :refunded, after: :publish_transaction_status_change
    end
  end

  def publish_transaction_status_change
    if go_cardless_id.present? && ak_donation_action_id.present?
      ChampaignQueue.push({
        type: 'payment-status-update',
        params: attributes.slice(
          'id', 'go_cardless_id', 'ak_order_id',
          'ak_donation_action_id',
          'ak_transaction_id', 'ak_user_id'
        ).merge!("payment_gateway_status": aasm.to_state.to_s)
      }, { group_id: "gocardless-transaction:#{id}" })
    end
  end

  def publish_failed_subscription_charge
    return publish_transaction_status_change if subscription.blank?
    return unless subscription.ak_order_id.present?

    ChampaignQueue.push({
      type: 'subscription-payment-failure',
      params: {
        recurring_id: subscription.go_cardless_id,
        success: 0,
        status: 'failed',
        trans_id: go_cardless_id,
        ak_order_id: subscription.ak_order_id
      }
    },
                        { group_id: "gocardless-subscription:#{id}" })
  end

  # def increment_funding_counter
  #   FundingCounter.update(page: page, currency: currency, amount: amount)
  # end

  def set_refund_and_creation_state
    self.newrecord     = new_record?
    self.refund_synced = refund_was
    true
  end

  def amount_affected
    refund? ? (amount_refunded * -1) : amount
  end

  def new_successful_transaction?
    newrecord
  end

  def successful_refund?
    !new_record? && !refund_synced && amount_refunded.present?
  end

  def update_funding_counter
    if new_successful_transaction? || successful_refund?
      FundingCounter.update(page: page, currency: currency, amount: amount_affected)
    else
      true
    end
  end
end
