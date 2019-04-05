# frozen_string_literal: true

# == Schema Information
#
# Table name: members
#
#  id                   :integer          not null, primary key
#  address1             :string
#  address2             :string
#  city                 :string
#  consented            :boolean
#  consented_updated_at :datetime
#  country              :string
#  donor_status         :integer          default("nondonor"), not null
#  email                :string
#  first_name           :string
#  last_name            :string
#  more                 :jsonb
#  postal               :string
#  title                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  actionkit_user_id    :string
#
# Indexes
#
#  index_members_on_actionkit_user_id  (actionkit_user_id)
#  index_members_on_email              (email)
#  index_members_on_email_and_id       (email,id)
#

class Member < ApplicationRecord
  has_many :go_cardless_customers, class_name: 'Payment::GoCardless::Customer'
  has_one :customer,               class_name: 'Payment::Braintree::Customer'
  has_one :braintree_customer,     class_name: 'Payment::Braintree::Customer'
  has_one :authentication, class_name: 'MemberAuthentication', dependent: :destroy
  has_many :payment_methods, through: :customer
  has_many :actions
  has_paper_trail on: %i[update destroy]

  delegate :authenticate, to: :authentication, allow_nil: true

  validates :email, uniqueness: { case_sensitive: true }, allow_nil: true

  before_validation { email.try(:downcase!) }
  before_save :update_consented_updated_at

  enum donor_status: %i[nondonor donor recurring_donor]

  def self.find_from_request(akid: nil, id: nil)
    member = find_by_akid(akid)
    return member if member.present?

    id.present? ? find_by(id: id) : nil
  end

  def self.find_by_akid(akid)
    actionkit_user_id = AkidParser.parse(akid, Settings.action_kit.akid_secret)[:actionkit_user_id]
    where(actionkit_user_id: actionkit_user_id).order('created_at ASC').first if actionkit_user_id.present?
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
    additional_values = {
      consented: consented,
      donor_status: donor_status,
      name: full_name,
      registered: authentication.present?,
      full_name: full_name,
      welcome_name: full_name.blank? ? email : full_name
    }
    (more || {}).merge(attributes).symbolize_keys.merge(additional_values)
  end

  def publish_signup(locale = nil)
    params = {
      email: email,
      name: name,
      country: country,
      postal: postal
    }
    params[:locale] = locale if locale.present?
    ChampaignQueue.push(
      { type: 'subscribe_member',
        params: params },
      { group_id: "member:#{id}" }
    )
  end

  def token_payload
    {
      id: id,
      email: email,
      authentication_id: authentication.try(:id)
    }
  end

  private

  def update_consented_updated_at
    self.consented_updated_at = Time.now if consented_changed?
  end
end
