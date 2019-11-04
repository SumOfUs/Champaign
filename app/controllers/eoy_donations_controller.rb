# frozen_string_literal: true

class EoyDonationsController < ApplicationController
  def opt_out
    opt_in_or_out('opt_out')
  end

  def opt_in
    opt_in_or_out('opt_in')
  end

  private

  def opt_in_or_out(option)
    akid = unsafe_params[:akid]
    @eoy_donation_email = EoyDonationEmail.new(akid)

    if @eoy_donation_email.send(option)
      flash.now[:notice] = I18n.t("eoy_donation_email.#{option}.notice")
    else
      flash.now[:alert] = I18n.t("eoy_donation_email.#{option}.alert")
    end
    render html: '', layout: true
  end
end
