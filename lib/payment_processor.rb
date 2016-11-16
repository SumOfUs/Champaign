# frozen_string_literal: true
module PaymentProcessor
  CURRENCY_SYMBOLS = {
    GBP: '&#163;',
    USD: '&#36;',
    EUR: '&#8364;'
  }.freeze

  CURRENCY_DEFAULT_SYMBOL = '&#36;'

  def self.currency_to_symbol(currency)
    CURRENCY_SYMBOLS.fetch(currency.upcase.to_sym, CURRENCY_DEFAULT_SYMBOL)
  end
end
