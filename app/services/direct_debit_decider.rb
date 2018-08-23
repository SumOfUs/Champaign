# frozen_string_literal: true

class DirectDebitDecider
  ALWAYS_COUNTRIES = %i[DE AT ES AU].freeze # Germany, Austria, Spain and Australia
  ONLY_RECURRING_COUNTRIES = %i[GB NL].freeze # Britain and Netherlands

  def self.decide(member_countries, recurring_default)
    new(member_countries, recurring_default).decide
  end

  def initialize(member_countries, recurring_default)
    @member_countries = member_countries.map { |country| country.to_s.upcase.to_sym }
    recurring_default = recurring_default.try(:to_sym)
    @recurring = (recurring_default == :only_recurring || recurring_default == :recurring)
  end

  def decide
    return true if (@member_countries & ALWAYS_COUNTRIES).any?
    member_country_shows_when_recurring = (@member_countries & ONLY_RECURRING_COUNTRIES).any?
    return true if @recurring && member_country_shows_when_recurring
    false
  end
end
