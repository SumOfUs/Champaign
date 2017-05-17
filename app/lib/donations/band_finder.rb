# frozen_string_literal: true
module Donations
  class BandFinder
    class << self
      def find_band(band_name, backup_id)
        band = DonationBand.find_by(name: band_name)
        band = DonationBand.find_by(id: backup_id) if band.blank?
        band = DonationBand.first if band.blank?
        band
      end
    end
  end
end
