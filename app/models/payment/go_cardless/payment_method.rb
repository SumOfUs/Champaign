class Payment::GoCardless::PaymentMethod < ActiveRecord::Base
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
