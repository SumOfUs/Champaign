# frozen_string_literal: true
require 'money'
require 'money/bank/google_currency'

module PaymentProcessor
  # = PaymentProcessor::Currency
  #
  # Wrapper for coverting currency. Converts from USD.
  #
  # == Usage
  #
  # Call <tt>PaymentProcessor::Currency.convert(1_20, :eur)</tt>
  #
  # Will return an instance of +Money+ - https://github.com/RubyMoney/money
  #
  # ==== Example
  #
  # Convert $1.50 to Euros.
  #
  #   amount = PaymentProcessor::Currency.convert(1_50, :eur)
  #   amount.format
  #   "€1.12"
  #
  class Currency
    # Cache fetche conversion rates.
    Money::Bank::GoogleCurrency.ttl_in_seconds = 86_400 # 24 hours
    Money.default_bank = Money::Bank::GoogleCurrency.new

    def self.convert(amount, end_currency, start_currency = 'USD')
      Money.new(amount, start_currency).exchange_to(end_currency)
    end
  end
end
