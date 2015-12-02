class AddDonationBandIdToFundraisers < ActiveRecord::Migration
  def change
    add_reference :plugins_fundraisers, :donation_band, index: true, foreign_key: true
  end
end
