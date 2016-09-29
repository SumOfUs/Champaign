# frozen_string_literal: true
class EmailConfirmationController < ApplicationController
  include AuthToken

  def verify

    if verifier.success?
      bake_cookies
    end

    @rendered = template.render(
      'errors' => verifier.errors,
      'members_dashboard_url' => Settings.members.dashboard_url
    ).html_safe
    ## FIXME seed and fetch from DB
    #
    render 'email_confirmation/follow_up', layout: 'generic'

  end

  private

  def verifier
    @verifier ||= AuthTokenVerifier.new(params[:token]).verify
  end

  def bake_cookies
    minutes_in_a_year = 1.year.abs / 60
    encoded_jwt = encode_jwt(verifier.authentication.member.token_payload, minutes_in_a_year)

    cookies.signed['authentication_id'] = {
      value: encoded_jwt,
      expires: 1.year.from_now
    }
  end

  def template
    @template ||= Liquid::Template.parse(File.read("#{Rails.root}/app/liquid/views/layouts/email-confirmation-follow-up.liquid"))
  end

end
