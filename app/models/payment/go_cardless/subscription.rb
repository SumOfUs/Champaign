class Payment::GoCardless::Subscription < ActiveRecord::Base

  class Charge
    attr_reader :subscription, :event

    delegate :action, :amount, :currency, to: :subscription

    def initialize(subscription, event = {})
      @event = event
      @subscription = subscription
    end

    def call
      if action.blank?
        # create the action
        # ManageGoCardlessDonation.create(attributes)
        #
        # WE should have an action at this point. I
        # think we should log if one isn't found.
      else
        number_of_payments = action.form_data.fetch('recurrence_number', 0) + 1
        action.form_data['recurrence_number'] = number_of_payments
        action.save

        transaction = Payment::GoCardless.write_transaction(event['links']['payment'], amount, currency, action.page.id)
        transaction.run_confirm!
        ActionQueue::Pusher.push(action)
      end
    end
  end
end

class Payment::GoCardless::Subscription < ActiveRecord::Base
  include AASM

  validates :go_cardless_id, presence: true, allow_blank: false

  belongs_to :page
  belongs_to :action
  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'
  belongs_to :payment_method, class_name: 'Payment::GoCardless::PaymentMethod'

  ACTION_FROM_STATE = {
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
      transitions to: :active, after: Payment::GoCardless::Subscription::Charge
    end
  end
end
