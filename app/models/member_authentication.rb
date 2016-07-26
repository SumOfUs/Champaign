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
# NOTE: Users that sign up with facebook will have a random password generated
# for them. This is to satisfy `has_secure_password` validations, and for as an
# added security measure.
class MemberAuthentication < ActiveRecord::Base
  has_secure_password

  belongs_to :member
  validates_uniqueness_of :member_id

  before_validation :generate_password, unless: :password?

  def facebook_oauth
    {
      uid: facebook_uid,
      oauth_token: facebook_token,
      oauth_token_expiry: facebook_token_expiry,
    }
  end

  protected

  def password?
    password_digest || password
  end

  def generate_password
    password = SecureRandom.base64(24)
    self.password = password
  end
end
