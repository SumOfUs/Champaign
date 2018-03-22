# frozen_string_literal: true

require 'money'
require 'money_oxr/bank'

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
  #   "EURO 1.12"
  #
  class Currency
    # Cache fetche conversion rates.
    # API provided by https://openexchangerates.org
    #
    Money.default_bank = MoneyOXR::Bank.new(
      app_id: Settings.oxr_app_id,
      cache_path: 'tmp/oxr.json',
      max_age: 86_400 # 24 hours
    )

    def self.convert(amount, end_currency, start_currency = 'USD')
      Money.new(amount, start_currency).exchange_to(end_currency)
    end
  end
end
