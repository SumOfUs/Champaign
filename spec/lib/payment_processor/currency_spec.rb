require 'rails_helper'
require 'vcr'

describe PaymentProcessor::Currency do
  it 'converts' do
    VCR.use_cassette('money_google_bank') do
      expect(
        PaymentProcessor::Currency.convert(100, 'eur').format
      ).to match( /€0[.,]\d\d/ )
    end
  end

  it 'raises with invalid currency' do
    expect{
      PaymentProcessor::Currency.convert(100.23, 'zzz').format
    }.to raise_error( Money::Currency::UnknownCurrency )
  end
end

