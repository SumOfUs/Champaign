# frozen_string_literal: true

class FundingCounter
  def initialize(page, currency, amount = nil)
    @page = page
    @currency = currency
    @amount = amount
  end

  def self.update(page, amount, currency)
    new(page, amount, currency).update
  end

  def self.convert(page, currency)
    new(page, currency).convert
  end

  def update
    return if @page.blank?
    converted_amount = Money.new(in_cents(@amount), @currency).exchange_to('USD')
    total_amount = @page.total_donations + converted_amount
    @page.update_attributes(total_donations: total_amount)
  end

  def convert
    Money.new(in_cents(@page.total_donations), 'USD').exchange_to(@currency)
  end

  private

  def in_cents(amount)
    # converts to rational to avoid round-off issues
    (100 * amount.to_r).to_i
  end
end
