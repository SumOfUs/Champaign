class Payment::GoCardless::Transaction < ActiveRecord::Base
  include AASM

  belongs_to :page
  belongs_to :action
  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'

  aasm do
    state :pending_customer_approval, initial: true
    state :pending_submission
    state :submitted
    state :confirmed
    state :paid_out
    state :cancelled
    state :customer_approval_denied
    state :failed
    state :charged_back

    event :run_submit do
      transitions from: [:pending_customer_approval, :pending_submission], to: :submitted
    end

    event :run_confirm do
      transitions from: [:pending_customer_approval, :pending_submission, :submitted], to: :confirmed
    end

    event :run_pay_out do
      transitions from: [:pending_customer_approval, :pending_submission, :submitted, :confirmed], to: :paid_out
    end

    event :run_deny do
      transitions to: :customer_approval_denied
    end

    event :run_cancel do
      transitions to: :cancelled
    end

    event :run_fail do
      transitions to: :failed
    end

    event :run_charge_back do
      transitions to: :charged_back
    end
  end

  validates :go_cardless_id, presence: true, allow_blank: false
end
