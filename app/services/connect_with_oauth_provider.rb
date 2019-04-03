# frozen_string_literal: true

# Raise if user's email domain is not whitelisted
class Champaign::NotWhitelisted < StandardError; end

class ConnectWithOauthProvider
  def self.connect(data)
    new(data).connect
  end

  def initialize(resp)
    @resp = resp
  end

  def connect
    raise Champaign::NotWhitelisted unless whitelisted

    return connected_user if user_already_connected

    return updated_disconnected_user if user_exists_but_disconnected

    create_user
  end

  private

  def whitelisted
    return true if whitelist.blank?

    whitelist.include? email_domain
  end

  def connected_user
    @connected_user ||= User.find_by(provider: @resp.provider, uid: @resp.uid)
  end

  def disconnected_user
    @disconnected_user ||= User.find_by(email: @resp.info.email)
  end

  def updated_disconnected_user
    disconnected_user.update_attributes(provider: @resp.provider, uid: @resp.uid)
    disconnected_user
  end

  def create_user
    @created_user ||= User.create!(
      provider: @resp.provider,
      email: @resp.info.email,
      uid: @resp.uid,
      password: Devise.friendly_token[0, 20]
    )
  end

  def email_domain
    @resp.info.email.split('@').last
  end

  def whitelist
    Settings.oauth_domain_whitelist
  end

  alias user_exists_but_disconnected disconnected_user
  alias user_already_connected connected_user
end
