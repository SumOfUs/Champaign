class Payment::BraintreeTransaction < ActiveRecord::Base
  belongs_to :page
  belongs_to :braintree_payment_method_token
  belongs_to :payment_braintree_customer
  enum status: [:success, :failure]

end
