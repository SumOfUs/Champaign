require 'rails_helper'

describe Donations::Currencies do
  describe '#for' do
    it 'converts and presents listed currencies' do
      VCR.use_cassette('donation_currencies') do
        expect(
          Donations::Currencies.for([1000,1000,3300,7200]).to_hash
        ).to eq( {
          USD: [10, 33, 72],
          GBP: [7, 20, 50],
          EUR: [9, 30, 70]
        }.to_hash )
      end
    end
  end
end

