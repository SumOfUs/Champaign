# frozen_string_literal: true

require 'rails_helper'

describe Donations::Currencies do
  describe '#for' do
    it 'converts and presents listed currencies as JSON' do
      VCR.use_cassette('donation_currencies') do
        conversions = Donations::Currencies.for([102, 204, 302, 401]).to_hash

        expect(conversions.keys.size).to eq(7)
        expect(conversions[:GBP].size).to eq(4)
      end
    end
  end
end
