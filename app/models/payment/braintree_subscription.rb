class Payment::BraintreeSubscription < ActiveRecord::Base
  belongs_to :page
end
