class Member < ActiveRecord::Base
  has_one :customer, class_name: "Payment::BraintreeCustomer"
  has_paper_trail on: [:update, :destroy]

  validates :email, uniqueness: true, allow_nil: true
  before_save { self.email.try(:downcase!) }

  def self.find_from_request(akid: nil, id: nil)
    if actionkit_user_id = AkidParser.parse(akid, Settings.action_kit.akid_secret)[:actionkit_user_id]
      member = where(actionkit_user_id: actionkit_user_id).order('created_at ASC').first
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
    full_name = name
    attributes.merge({
      name: full_name,
      full_name: full_name,
      welcome_name: full_name.blank? ? email : full_name
    })
  end
end
