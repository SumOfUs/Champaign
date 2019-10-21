# frozen_string_literal: true

class EoyDonationsController < ApplicationController
  before_action :set_member

  def opt_out
    @eoy_donation_email = EoyDonationEmail.new(@member)

    if @eoy_donation_email.opt_out
      flash.now[:notice] = 'You have successfully opted out EOY donation email'
    else
      flash.now[:alert] = 'Error occured while opting out EOY donation email'
    end
    render html: '', layout: true
  end

  def opt_in
    @eoy_donation_email = EoyDonationEmail.new(@member)

    if @eoy_donation_email.opt_in
      flash.now[:notice] = 'You have successfully opted in EOY donation email'
    else
      flash.now[:alert] = 'Error occured while opting in EOY donation email'
    end
    render html: '', layout: true
  end

  def set_member
    member_id = params[:member_id]
    @member ||= Member.find_by(actionkit_user_id: member_id)
  end
end
