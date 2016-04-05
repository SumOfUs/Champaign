class Payment::GoCardless::Transaction < ActiveRecord::Base
  belongs_to :page
  belongs_to :action
  belongs_to :customer, class_name: 'Payment::Braintree::Customer'
  belongs_to :payment_method, class_name: 'Payment::Braintree::PaymentMethod'

  enum status: [:pending_customer_approval,
                :pending_submission,
                :submitted,
                :confirmed,
                :paid_out,
                :cancelled,
                :customer_approval_denied,
                :failed,
                :charged_back]

  validates :status, presence: true, allow_blank: false
  validates :go_cardless_id, presence: true, allow_blank: false
end
