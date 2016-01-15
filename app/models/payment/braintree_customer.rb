class Payment::BraintreeCustomer < ActiveRecord::Base
  belongs_to :member
end
