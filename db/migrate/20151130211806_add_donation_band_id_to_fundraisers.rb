# frozen_string_literal: true

class AddDonationBandIdToFundraisers < ActiveRecord::Migration[4.2]
  def change
    add_reference :plugins_fundraisers, :donation_band, index: true, foreign_key: true
  end
end
