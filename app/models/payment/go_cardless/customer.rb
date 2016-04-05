class Payment::GoCardless::Customer < ActiveRecord::Base
  belongs_to :member

  has_many :payment_methods, class_name: 'Payment::GoCardless::PaymentMethods'
  has_many :transactions, class_name: 'Payment::GoCardless::Transactions'
  has_many :subscriptions, class_name: 'Payment::GoCardless::Subscriptions'

  validates :go_cardless_id, presence: true, allow_blank: false
end
