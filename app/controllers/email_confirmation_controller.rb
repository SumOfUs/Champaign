# frozen_string_literal: true
class EmailConfirmationController < ApplicationController
  def verify
    @member = Member.find_by(email: params[:email])

    errors = EmailVerifierService.verify(params[:token], params[:email], cookies)

    @rendered = template.render(
      'errors' => errors,
      'members_dashboard_url' => Settings.members.dashboard_url
    ).html_safe

    render 'email_confirmation/follow_up', layout: 'generic'
  end

  private

  def template
    ## FIXME seed and fetch from DB
    #
    view = File.read("#{Rails.root}/app/liquid/views/layouts/email-confirmation-follow-up.liquid")
    @template ||= Liquid::Template.parse(view)
  end
end
