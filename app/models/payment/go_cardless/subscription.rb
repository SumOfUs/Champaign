class Payment::GoCardless::Subscription < ActiveRecord::Base
  include AASM

  belongs_to :page
  belongs_to :action
  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'

   aasm do
    state :pending_customer_approval, initial: true
    state :customer_approval_denied
    state :active
    state :finished
    state :cancelled

    event :run_activate do
      transitions from: [:pending_customer_approval], to: :active
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
  end

  validates :go_cardless_id, presence: true, allow_blank: false
end
