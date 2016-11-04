# frozen_string_literal: true
#
# MemberAuthentication contains a member's authentication tokens
# for all providers:
#
# If the user decided to create a password (instead of using social login),
# we will store their hashed password here (using `has_secure_password`).
# To authentiacate: `member_authentication.try(:authenticate, 'password')`
#   - password_digest
#
# If the user signed up with Facebook, we store some important information
# in order to authenticate them later on:
#   - facebook_uid
#   - facebook_token
#   - facebook_expiry
#
class MemberAuthentication < ActiveRecord::Base
  VALID_TOKEN_AGE_IN_DAYS = 1

  has_secure_password

  validates :member_id, uniqueness: true, presence: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  before_create :set_token
  belongs_to :member

  delegate :email, to: :member

  def facebook_oauth
    {
      uid: facebook_uid,
      oauth_token: facebook_token,
      oauth_token_expiry: facebook_token_expiry
    }
  end

  def authenticate(password)
    confirmed_at.present? && super(password).present?
  end

  def confirm
    if confirmed_at.nil?
      update(
        confirmed_at: Time.now,
        token: nil
      )
    end

    confirmed_at
  end

  def reset_password(password, confirmed_password)
    update(
      password: password,
      password_confirmation: confirmed_password
    )
  end

  def set_reset_password_token
    update(
      reset_password_token: SecureRandom.urlsafe_base64(30),
      reset_password_sent_at: Time.now
    )
  end

  def self.find_by_valid_reset_password_token(token)
    MemberAuthentication.where(
      reset_password_token: token,
      reset_password_sent_at: VALID_TOKEN_AGE_IN_DAYS.days.ago..Time.now
    ).first
  end

  def self.find_by_email(email)
    Member.find_by(email: email).try(:authentication)
  end

  private

  def set_token
    self.token = SecureRandom.base64(24) unless token.present?
  end
end
