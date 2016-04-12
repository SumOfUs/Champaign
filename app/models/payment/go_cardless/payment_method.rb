class Payment::GoCardless::PaymentMethod < ActiveRecord::Base
  include Statesman::Machine

  state :pending, initial: true
  state :created
  state :submitted
  state :active
  state :cancelled
  state :expired
  state :failed
  state :resubmission_requested

  #transition from: :pending,      to: [:created]
  #transition from: :checking_out, to: [:purchased, :cancelled]
  #transition from: :purchased,    to: [:shipped, :failed]
  #transition from: :shipped,      to: :refunded

  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'

  enum status: [:pending_submission,
                :submitted,
                :active,
                :failed,
                :cancelled,
                :expired]

  validates :status, presence: true, allow_blank: false
  validates :go_cardless_id, presence: true, allow_blank: false
end
