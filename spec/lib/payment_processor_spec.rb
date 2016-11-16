# frozen_string_literal: true
require './lib/payment_processor'
require 'spec_helper'

describe PaymentProcessor do
  describe '.currency_to_symbol' do
    it 'returns symbol from currency' do
      expect(
        PaymentProcessor.currency_to_symbol('EUR')
      ).to eq('&#8364;')

      expect(
        PaymentProcessor.currency_to_symbol(:GBP)
      ).to eq('&#163;')

      expect(
        PaymentProcessor.currency_to_symbol('eur')
      ).to eq('&#8364;')
    end

    it 'returns $ as default' do
      expect(
        PaymentProcessor.currency_to_symbol('CAD')
      ).to eq('&#36;')
    end
  end
end
