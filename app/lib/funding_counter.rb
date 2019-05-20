# frozen_string_literal: true

class FundingCounter
  def initialize(page, currency, amount = nil)
    @page     = page
    @currency = currency
    @amount   = amount
  end

  def self.update(page:, currency:, amount:)
    new(page, currency, amount).update
  end

  def self.convert(currency:, amount:)
    new(nil, currency, amount).convert
  end

  def original_amount
    Money.new(@page.total_donations, Settings.default_currency)
  end

  def converted_amount
    Money.from_amount(@amount, @currency).exchange_to(Settings.default_currency)
  end

  def update
    return if @page.blank?

    total_donations = (original_amount.cents + converted_amount.cents)
    @page.update_attributes(total_donations: total_donations)
  end

  def convert
    Money.from_amount(@amount, Settings.default_currency).exchange_to(@currency)
  end
end
