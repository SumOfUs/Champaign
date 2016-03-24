class Payment::BraintreeTransaction < ActiveRecord::Base
  belongs_to :page
  belongs_to :braintree_payment_method_token
  belongs_to :customer, class_name: Payment::BraintreeCustomer
  enum status: [:success, :failure]

end
