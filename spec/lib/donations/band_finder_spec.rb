require 'rails_helper'
require './lib/donations/band_finder'

describe Donations::BandFinder do
  let(:band_name) { 'Wyld Stallyns' }
  let!(:donation_band) { DonationBand.create!(name: band_name, amounts: [1, 2, 3]) }

  it 'finds the band by name' do
    expect(Donations::BandFinder.find_band(band_name, 100)).to eq(donation_band)
  end

  it 'finds the band by backup ID' do
    expect(Donations::BandFinder.find_band('Bad name', 1)).to eq(donation_band)
  end

  it 'finds the backup first band' do
    expect(Donations::BandFinder.find_band('Bad name', 100)).to eq(donation_band)
  end
end
