# frozen_string_literal: true

class EoyDonationsController < ApplicationController
  include ExceptionHandler
  skip_before_action :verify_authenticity_token
  before_action :set_eoy_donation_email

  def opt_out
    opt_in_or_out('opt_out')
  end

  def opt_in
    opt_in_or_out('opt_in')
  end

  private

  def opt_in_or_out(option)
    unless @eoy_donation_email.confirmation_email_matched?(params[:email])
      render(json: { success: false, msg: I18n.t('eoy_donation_email.confirmation_error') },
             status: :unprocessable_entity) && (return false)
    end

    if @eoy_donation_email.send(option)
      render json: { success: true, msg: I18n.t("eoy_donation_email.#{option}.notice") }
    else
      render json: { success: false, msg: I18n.t("eoy_donation_email.#{option}.alert") }, status: :unprocessable_entity
    end
  end

  def set_eoy_donation_email
    akid = unsafe_params[:akid]
    @eoy_donation_email = EoyDonationEmail.new(akid)
  end
end
