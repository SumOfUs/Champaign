require 'rails_helper'
require 'vcr'

describe PaymentProcessor::Currency do
  it 'converts from USD' do
    VCR.use_cassette('money_google_bank_from_usd') do
      expect(
        PaymentProcessor::Currency.convert(100, 'eur').format
      ).to match( /€0[.,]\d\d/ )
    end
  end

  it 'converts from GBP' do
    VCR.use_cassette('money_google_bank_from_gbp') do
      expect(
        PaymentProcessor::Currency.convert(1000, 'eur', 'gbp').cents
      ).to be_between(1100, 1400)
    end
  end

  it 'raises with invalid currency' do
    expect{
      PaymentProcessor::Currency.convert(100.23, 'zzz').format
    }.to raise_error( Money::Currency::UnknownCurrency )
  end
end

