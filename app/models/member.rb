# frozen_string_literal: true
# == Schema Information
#
# Table name: members
#
#  id                :integer          not null, primary key
#  email             :string
#  country           :string
#  first_name        :string
#  last_name         :string
#  city              :string
#  postal            :string
#  title             :string
#  address1          :string
#  address2          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  actionkit_user_id :string
#  donor_status      :integer          default(0), not null
#

class Member < ActiveRecord::Base
  has_many :go_cardless_customers, class_name: 'Payment::GoCardless::Customer'
  has_one :customer,               class_name: 'Payment::Braintree::Customer'
  has_one :braintree_customer,     class_name: 'Payment::Braintree::Customer'
  has_one :authentication, class_name: MemberAuthentication, dependent: :destroy
  has_many :payment_methods, through: :customer
  has_many :actions
  has_paper_trail on: [:update, :destroy]

  delegate :authenticate, to: :authentication, allow_nil: true

  validates :email, uniqueness: { case_sensitive: true }, allow_nil: true

  before_validation { email.try(:downcase!) }

  enum donor_status: [:nondonor, :donor, :recurring_donor]

  def self.find_from_request(akid: nil, id: nil)
    member = find_by_akid(akid)
    return member if member.present?
    id.present? ? find_by(id: id) : nil
  end

  def self.find_by_akid(akid)
    actionkit_user_id = AkidParser.parse(akid, Settings.action_kit.akid_secret)[:actionkit_user_id]
    if actionkit_user_id.present?
      where(actionkit_user_id: actionkit_user_id).order('created_at ASC').first
    end
  end

  def self.find_by_email(email)
    Member.find_by(email: email.try(:downcase))
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
    attributes.symbolize_keys.merge(donor_status: donor_status, # to get the string not enum int
                                    name: full_name,
                                    registered: authentication.present?,
                                    full_name: full_name,
                                    welcome_name: full_name.blank? ? email : full_name)
  end

  def publish_subscription
    ChampaignQueue.push(
      type: 'subscribe_member',
      params: {
        email: email,
        name: name,
        country: country,
        postal: postal

      }
    )
  end

  def token_payload
    {
      id: id,
      email: email,
      authentication_id: authentication.try(:id)
    }
  end
end
