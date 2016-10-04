# frozen_string_literal: true
#
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

  class << self
    def create(params)
      member = Member.create(params.except('password', 'password_confirmation'))
      member.create_authentication(password: params['password'])
      member
    end
  end
end
