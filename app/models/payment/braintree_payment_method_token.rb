class Payment::BraintreePaymentMethodToken < ActiveRecord::Base
  belongs_to :customer, class_name: Payment::BraintreeCustomer
  has_many :braintree_transactions, class_name: Payment::Braintreetransaction
end
