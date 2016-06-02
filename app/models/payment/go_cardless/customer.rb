class Payment::GoCardless::Customer < ActiveRecord::Base
  belongs_to :member

  has_many :payment_methods, class_name: 'Payment::GoCardless::PaymentMethod'
  has_many :transactions, class_name: 'Payment::GoCardless::Transaction'
  has_many :subscriptions, class_name: 'Payment::GoCardless::Subscription'

  validates :go_cardless_id, presence: true, allow_blank: false
end
