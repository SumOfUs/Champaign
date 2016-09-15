# frozen_string_literal: true
class EmailConfirmationController < ApplicationController
  def verify
    @errors = AuthTokenVerifier.verify(params)
    view = File.read("#{Rails.root}/app/liquid/views/layouts/email_confirmation_landing.liquid")
    @template = Liquid::Template.parse(view)
    render text: @template.render('errors' => @errors), content_type: :html
  end
end
