# frozen_string_literal: true

class Api::MemberServicesController < ApplicationController
  # TODO: Authenticate

  def cancel_recurring_donation
    donations_updater = MemberServicesDonationsUpdater.new(permitted_params.to_h)

    if donations_updater.cancel
      respond_to do |format|
        format.json { render json: { recurring_donation: donations_updater.resource }, status: 200 }
      end
    else
      render json: { errors: donations_updater.errors }, status: donations_updater.status
    end
  end

  private

  def permitted_params
    params.permit(:provider, :id)
  end
end
