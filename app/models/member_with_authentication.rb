# frozen_string_literal: true

class MemberWithAuthentication
  include ActiveModel::Model

  validates :password, length: { minimum: 6 }, allow_nil: true
  validates :email, presence: true

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

      if record.valid?
        record.create_member_with_authentication(params)
      end

      record
    end
  end

  def create_member_with_authentication(params)
    ActiveRecord::Base.transaction do
      params = params.stringify_keys
      @member = Member.create(params.except('password', 'password_confirmation'))
      @authentication = member.create_authentication(password: params['password'])
    end

    self
  end
end
