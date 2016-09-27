# frozen_string_literal: true
class EmailConfirmationController < ApplicationController
  include AuthToken

  def verify
    verifier = AuthTokenVerifier.new(params[:token]).verify

    ## FIXME seed and fetch from DB
    #
    view = File.read("#{Rails.root}/app/liquid/views/layouts/email-confirmation-follow-up.liquid")
    template = Liquid::Template.parse(view)

    if verifier.success?
      minutes_in_a_year = 1.year.abs / 60
      encoded_jwt = encode_jwt(verifier.authentication.member.token_payload, minutes_in_a_year)

      cookies.signed['authentication_id'] = {
        value: encoded_jwt,
        expires: 1.year.from_now
      }
    end

    @rendered = template.render(
      'errors' => verifier.errors,
      'members_dashboard_url' => Settings.members.dashboard_url
    ).html_safe

    render 'email_confirmation/follow_up', layout: 'generic'
  end
end
