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
    VALID_CURRENCIES = [:GBP, :EUR]

    def self.for(amounts)
      new(amounts).convert
    end

    def initialize(amounts)
      @amounts = amounts
      @currencies = { USD: @amounts.map{ |val| Money.new(val).to_s }  }
    end

    def convert
      VALID_CURRENCIES.each do |currency|
        @currencies[currency] = @amounts.map do |val|
          PaymentProcessor::Currency.convert( val, currency ).to_s
        end
      end

      self
    end

    def round(amounts)
      amounts.map do |am|
        # round to integer if below 20, round to nearest 5 if above
        am.to_f <= 20 ? am.to_f.round : (am.to_f / 5).round * 5
      end.map(&:to_i)
    end

    def deduplicate(amounts)
      duplicates = amounts.group_by{ |e| e }.select{ |k, v| v.size > 1 }.values.flatten # duplicates
      safe = amounts - duplicates
      duplicates.each do |misfit|
        while safe.include? misfit
          if misfit < 20 then misfit += 1 else misfit += 5 end
        end
        safe << misfit
      end
      safe.sort
    end

    def to_hash
      @currencies
    end
  end
end

