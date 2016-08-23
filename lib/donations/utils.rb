# frozen_string_literal: true
module Donations
  module Utils
    extend self
    EURO_COUNTRY_CODES = [:AL, :AD, :AT, :BY, :BE, :BA, :BG, :HR, :CY, :CZ, :DK, :EE, :FO, :FI, :FR, :DE, :GI, :GR, :HU, :IS, :IE, :IT, :LV, :LI, :LT, :LU, :MK, :MT, :MD, :MC, :NL, :NO, :PL, :PT, :RO, :RU, :SM, :RS, :SK, :SI, :ES, :SE, :CH, :UA, :VA, :RS, :IM, :RS, :ME].freeze
    DEFAULT_CURRENCY = 'USD'

    def round_and_dedup(values)
      deduplicate(round(values))
    end

    def round(values)
      values.map do |value|
        value = value.to_f

        if value < 20
          value = value.round(0)
          if value.zero?
            1.to_f
          else
            value
          end
        else
          (value.to_f / 5).round * 5
        end
      end
    end

    def deduplicate(values)
      duplicates = values.group_by { |e| e }.select { |_k, v| v.size > 1 }.values.flatten

      safe = values - duplicates

      duplicates.each do |misfit|
        misfit += (misfit < 20 ? 1 : 5) while safe.include? misfit
        safe << misfit
      end
      safe.sort
    end

    def currency_from_country_code(country_code)
      return 'EUR' if EURO_COUNTRY_CODES.include?(country_code.to_s.to_sym)
      {
        US: 'USD',
        GB: 'GBP',
        NZ: 'NZD',
        AU: 'AUD',
        CA: 'CAD'
      }[country_code.to_s.to_sym] || DEFAULT_CURRENCY
    end
  end
end
