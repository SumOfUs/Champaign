class Payment::GoCardless::PaymentMethod < ActiveRecord::Base
  include AASM

  aasm do
    state :pending, initial: true
    state :created
    state :submitted
    state :active
    state :cancelled
    state :expired

    event :has_been_created do
      transitions from: [:pending], to: :created
    end

    event :has_been_submitted do
      transitions from: [:pending, :created], to: :submitted
    end

    event :has_been_activated do
      transitions from: [:pending, :created, :submitted], to: :active
    end

    event :has_been_cancelled do
      transitions from: [:active], to: :cancelled
    end
  end

  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'

  validates :go_cardless_id, presence: true, allow_blank: false
end
