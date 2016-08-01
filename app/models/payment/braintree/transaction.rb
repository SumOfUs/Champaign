class Payment::Braintree::Transaction < ActiveRecord::Base
  belongs_to :page
  belongs_to :payment_method, class_name: 'Payment::Braintree::PaymentMethod'
  belongs_to :customer,       class_name: 'Payment::Braintree::Customer', primary_key: 'customer_id'
  belongs_to :subscription,   class_name: 'Payment::Braintree::Subscription'
  enum status: [:success, :failure]
end
