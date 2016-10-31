# frozen_string_literal: true

class MemberWithAuthentication
  # Brings in Rails' validation API to allow easy validation.
  include ActiveModel::Model

  validates :password, length: { minimum: 6 }, allow_nil: true
  validates :email, presence: true
  validate  :cannot_be_already_authenticated, :cannot_have_non_matching_passwords

  attr_accessor(:first_name,
                :last_name,
                :name,
                :email,
                :country,
                :city,
                :postal,
                :address1,
                :address2,
                :password,
                :password_confirmation)

  attr_reader :member, :authentication

  class << self
    def create(params)
      record = new(params)

      record.create_member_with_authentication(params) if record.valid?

      record
    end
  end

  def create_member_with_authentication(params)
    ActiveRecord::Base.transaction do
      params = params.stringify_keys

      @member = existing_member || Member.create(params.except('password', 'password_confirmation'))
      @authentication = member.create_authentication(password: params['password'])
    end

    self
  end

  def existing_member
    @existing_member ||= Member.find_by_email(email)
  end

  def cannot_be_already_authenticated
    errors.add(:authentication, 'already exists') if existing_member && existing_member.authentication
  end

  def cannot_have_non_matching_passwords
    errors.add(:password, "don't match") if password != password_confirmation
  end
end
