class Payment::BraintreeSubscription < ActiveRecord::Base
  belongs_to :page
  belongs_to :action
end
