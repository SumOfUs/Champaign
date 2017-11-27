# frozen_string_literal: true

class Api::MemberServicesController < ApplicationController
  # TODO: Authenticate

  def cancel_recurring_donation
    @provider = permitted_params[:provider]
    @donations_updater = MemberServicesDonationsUpdater.new(permitted_params.to_h)

    if @donations_updater.cancel
      render 'api/member_services/cancel_recurring_donation', status: 200
    else
      render json: { errors: @donations_updater.errors }, status: @donations_updater.status
    end
  end

  private

  def permitted_params
    @permitted_params ||= params.permit(:provider, :id)
  end
end
