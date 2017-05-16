# frozen_string_literal: true

class DonationBandConverter
  class << self
    def convert_for_saving(amounts)
      amounts.split(' ').uniq.map(&:to_i)
    end
  end
end
