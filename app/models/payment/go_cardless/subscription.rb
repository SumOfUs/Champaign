class Payment::GoCardless::Subscription < ActiveRecord::Base
  include AASM

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
      after do
        charge!
      end
      transitions to: :active
    end
  end

  validates :go_cardless_id, presence: true, allow_blank: false

  def charge!
    if action.blank?
      # create the action
      # ManageGoCardlessDonation.create(attributes)
    else
      action.form_data['recurrence_number'] += 1
      action.save
      # this API needs to be reconciled with what tuuli's writing
      # Payment::GoCardless.write_transaction(payment_method, gc_payment, page_id, member, false)
      ActionQueue::Pusher.push(action)
    end
  end
end
