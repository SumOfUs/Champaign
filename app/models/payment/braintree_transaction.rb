class Payment::BraintreeTransaction < ActiveRecord::Base
  belongs_to :page

end
