# frozen_string_literal: true
# == Currency Converter to JSON
#
# Takes an array of integer amounts, in US cents, and
# converts to GBP and EUR.
#
# ==== Examples
#
#   currencies = Donations::Currencies.for(102, 204, 302, 401)
#   currencies.to_hash # also to_json
#   =>
#   {
#     USD: [1.02, 2.04, 3.02, 4.01],
#     GBP: [0.67, 1.35, 2.0, 2.65],
#     EUR: [0.96, 1.92, 2.85, 3.79]
#    }
#

module Donations
  class Currencies
    # Array of currency codes to convert to.
    VALID_CURRENCIES = [:GBP, :EUR, :AUD, :NZD, :CAD].freeze

    def self.for(amounts)
      new(amounts).convert
    end

    def initialize(amounts)
      @amounts = amounts
      @currencies = { USD: @amounts.map { |val| Money.new(val).to_s } }
    end

    def convert
      VALID_CURRENCIES.each do |currency|
        @currencies[currency] = @amounts.map do |val|
          PaymentProcessor::Currency.convert(val, currency).to_s
        end
      end

      self
    end

    def to_hash
      @currencies
    end
  end
end
