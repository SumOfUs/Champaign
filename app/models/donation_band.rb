# frozen_string_literal: true
class DonationBand < ActiveRecord::Base
  has_paper_trail

  def internationalize
    converted = ::Donations::Currencies.for(amounts).to_hash
    converted.map { |k, vals| [k, ::Donations::Utils.round_and_dedup(vals)] }.to_h
  end
end
