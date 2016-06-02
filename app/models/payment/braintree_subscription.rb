class Payment::BraintreeSubscription < ActiveRecord::Base
  belongs_to :page
  belongs_to :action
  has_many   :transactions, class_name: 'Payment::BraintreeTransaction', foreign_key: :subscription_id
end
