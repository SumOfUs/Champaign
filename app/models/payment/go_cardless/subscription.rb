class Payment::GoCardless::Subscription < ActiveRecord::Base
  include AASM

  belongs_to :page
  belongs_to :action
  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'

  STATE_FROM_ACTION = {
    created:                    :create,
    cancelled:                  :cancel,
    payment_created:            :payment_create,
    customer_approval_granted:  :approve,
    customer_approval_denied:   :deny
  }

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
      puts "PAYMENT CREATED"
      transitions from: :active, to: :active

    end
  end

  validates :go_cardless_id, presence: true, allow_blank: false
end
