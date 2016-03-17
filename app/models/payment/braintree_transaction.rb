class Payment::BraintreeTransaction < ActiveRecord::Base
  belongs_to :page
  belongs_to :braintree_payment_method_token
  enum status: [:success, :failure]

end
