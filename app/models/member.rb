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

  def name
    "#{first_name} #{last_name}".strip
  end

  def name=(full_name)
    splitter = NameSplitter.new(full_name: full_name)
    self.first_name = splitter.first_name
    self.last_name = splitter.last_name
  end

  def liquid_data
    attributes.merge({
      name: name,
      welcome_name: name.blank? ? email : name
    })
  end
end
