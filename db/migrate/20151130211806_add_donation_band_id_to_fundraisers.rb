class AddDonationBandIdToFundraisers < ActiveRecord::Migration
  def change
    add_column :plugins_fundraisers, :donation_band_id, :integer
    add_foreign_key :plugins_fundraisers, :donation_bands
  end
end
