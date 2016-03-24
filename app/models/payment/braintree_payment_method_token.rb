class Payment::BraintreePaymentMethodToken < ActiveRecord::Base
  belongs_to :customer, class_name: Payment::BraintreeCustomer, foreign_key: :customer_id
end
