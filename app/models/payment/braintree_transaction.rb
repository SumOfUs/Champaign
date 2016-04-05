class Payment::BraintreeTransaction < ActiveRecord::Base
  belongs_to :page
  belongs_to :payment_method, class_name: Payment::BraintreePaymentMethod
  belongs_to :customer,       class_name: Payment::BraintreeCustomer
  enum status: [:success, :failure]
end
