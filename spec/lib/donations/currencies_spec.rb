require 'rails_helper'

describe Donations::Currencies do
  describe '#for' do
    it 'converts and presents listed currencies as JSON' do
      VCR.use_cassette('donation_currencies') do
        expect(
          Donations::Currencies.for([102,204,302,401]).to_json
        ).to eq( {
          USD: ['1.02', '2.04', '3.02', '4.01'],
          GBP: ['0.67', '1.35', '2.00', '2.65'],
          EUR: ['0.96', '1.92', '2.85', '3.79']
        }.to_json )
      end
    end
  end
end

