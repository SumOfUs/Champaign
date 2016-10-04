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
  has_secure_password

  validates :member_id, uniqueness: true, presence: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  before_create :set_token

  belongs_to :member

  def facebook_oauth
    {
      uid: facebook_uid,
      oauth_token: facebook_token,
      oauth_token_expiry: facebook_token_expiry
    }
  end

  private

  def set_token
    self.token = SecureRandom.base64(24)
  end
end
