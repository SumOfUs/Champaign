# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_go_cardless_transactions
#
#  id                :integer          not null, primary key
#  go_cardless_id    :string
#  charge_date       :date
#  amount            :decimal(, )
#  description       :string
#  currency          :string
#  status            :integer
#  reference         :string
#  amount_refunded   :decimal(, )
#  page_id           :integer
#  payment_method_id :integer
#  customer_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  aasm_state        :string
#  subscription_id   :integer
#

class Payment::GoCardless::Transaction < ActiveRecord::Base
  include AASM

  belongs_to :page
  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'
  belongs_to :subscription, class_name:   'Payment::GoCardless::Subscription'

  validates :go_cardless_id, presence: true, allow_blank: false

  scope :one_off, -> { where(subscription_id: nil) }

  ACTION_FROM_STATE = {
    submitted:     :submit,
    confirmed:     :confirm,
    cancelled:     :cancel,
    failed:        :fail,
    charged_back:  :charge_back,
    paid_out:      :pay_out
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
      transitions from: [:created, :submitted], to: :confirmed
    end

    event :run_payout do
      transitions from: [:created, :submitted, :confirmed], to: :paid_out
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
        status: 'failed'
      }
    }, { delay: 120 })
  end
end
