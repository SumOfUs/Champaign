class Payment::BraintreeCustomer < ActiveRecord::Base
  belongs_to :member
  has_many :braintree_payment_methods, class_name: Payment::BraintreePaymentMethod, primary_key: :customer_id, foreign_key: :customer_id
  belongs_to :default_payment_method, class_name: Payment::BraintreePaymentMethod
end
