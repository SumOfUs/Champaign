class Member < ActiveRecord::Base
  has_one :customer, class_name: "Payment::BraintreeCustomer"
  has_paper_trail on: [:update, :destroy]

  def self.find_from_request(akid: nil, id: nil)
    if akid.present?
      actionkit_user_id = AkidParser.parse(akid)[:actionkit_user_id]
      member = find_by(actionkit_user_id: actionkit_user_id)
      return member if member.present?
    end
    id.present? ? find_by(id: id) : nil
  end
end
