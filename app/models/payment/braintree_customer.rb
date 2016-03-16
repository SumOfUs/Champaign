class Payment::BraintreeCustomer < ActiveRecord::Base
  belongs_to :member
  has_many :braintree_payment_method_tokens, class_name: Payment::BraintreePaymentMethodToken
end
