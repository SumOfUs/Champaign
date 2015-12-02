module Donations
  class BandFinder
    class << self
      def find_band(band_name, backup_id)
        name_find = DonationBand.where(name: band_name).first
        if name_find
          name_find
        else
          begin
            DonationBand.find(backup_id)
          rescue
            DonationBand.first
          end
        end
      end
    end
  end
end
