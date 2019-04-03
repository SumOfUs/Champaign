# frozen_string_literal: true

class DonationBandsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_donation_band, only: %i[edit update]

  def new
    @donation_band = DonationBand.new
  end

  def create
    @donation_band = DonationBand.create permitted_params
    redirect_to :donation_bands, notice: t('donation_bands.create.notice')
  end

  def edit
    # Intentionally left blank.
  end

  def update
    @donation_band.update permitted_params
    redirect_to :donation_bands, notice: t('donation_bands.update.notice')
  end

  private

  def permitted_params
    values = params.require(:donation_band).permit(:id, :name, :amounts)
    values[:amounts] = DonationBandConverter.convert_for_saving(values[:amounts])
    values
  end

  def find_donation_band
    @donation_band = DonationBand.find(params[:id])
  end
end
