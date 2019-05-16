# frozen_string_literal: true

class FundingCounter
  def initialize(page, currency, amount = nil, refund = false)
    @page     = page
    @currency = currency
    @amount   = amount
    @refund   = refund
  end

  def self.update(page:, currency:, amount:, refund: false)
    new(page, currency, amount, refund).update
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

    total_donations = if @refund
                        (original_amount.cents - converted_amount.cents)
                      else
                        (original_amount.cents + converted_amount.cents)
                      end
    @page.update_attributes(total_donations: total_donations)
  end

  def convert
    Money.from_amount(@amount, Settings.default_currency).exchange_to(@currency)
  end
end
