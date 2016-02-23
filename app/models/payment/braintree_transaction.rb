class Payment::BraintreeTransaction < ActiveRecord::Base
  belongs_to :page
  enum status: [:success, :failure]

end
