require 'rails_helper'

describe Donations::Currencies do
  describe '#for' do
    it 'converts and presents listed currencies as JSON' do
      VCR.use_cassette('donation_currencies') do
        conversions = Donations::Currencies.for([102,204,302,401]).to_hash

        conversions.keys.each do |key|
          expect([:USD, :GBP, :EUR]).to include(key)
        end

        expect(conversions[:GBP].size).to eq(4)
      end
    end
  end
end

