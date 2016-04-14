class Payment::BraintreePaymentMethod < ActiveRecord::Base
  belongs_to :customer,     class_name: 'Payment::BraintreeCustomer'
  has_many   :transactions, class_name: 'Payment::BraintreeTransaction', foreign_key: 'payment_method_id'
end
