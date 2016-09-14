# frozen_string_literal: true
class AuthTokenVerifier
  def self.verify(params)
    self.new(params).verify
  end

  def initialize(params)
    @errors = assign_instance_variables(params)
  end

  def verify
    return @errors if @errors.any?
    return if valid_token?
    Rails.logger.error("Token verification failed for email #{@member.email} with token #{@token}.")
    ["Your confirmation token appears to be invalid. Our developers have been notified."]
  end

  private

  def assign_instance_variables(params)
    @token = params[:token]
    @member = Member.find_by!(email: params[:email])
    @member_auth = @member.authentication
    []
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Member or authentication record not found for #{@member} with token #{@token}.")
    ["There was an error retrieving your records. We've been notified and will look into it."]
  end

  def valid_token?
    if @member_auth.token == @token
      if @member_auth.confirmed_at.blank?
        @member_auth.update(confirmed_at: Time.now)
      end
      true
    else
      false
    end
  end
end
