# frozen_string_literal: true
class EmailConfirmationController < ApplicationController
  def verify
    @errors = AuthTokenVerifier.verify(params)
    view = File.read("#{Rails.root}/app/liquid/views/layouts/email_confirmation_follow_up.liquid")
    template = Liquid::Template.parse(view)

    @rendered = template.render('errors' => @errors, 'success' => @errors.blank?).html_safe
    render 'email_confirmation/follow_up', layout: 'generic'

  end
end
