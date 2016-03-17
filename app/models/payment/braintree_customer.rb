class Payment::BraintreeCustomer < ActiveRecord::Base
  belongs_to :member
  has_many :braintree_payment_method_tokens, class_name: Payment::BraintreePaymentMethodToken
  belongs_to :default_payment_method_token, class_name: Payment::BraintreePaymentMethodToken
end
