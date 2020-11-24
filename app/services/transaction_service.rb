# frozen_string_literal: true

module TransactionService
  extend self
  CURRENCIES = %i[USD GBP EUR CHF AUD NZD CAD MXN ARS].freeze

  def totals(date_range = Float::INFINITY..Float::INFINITY)
    Rails.cache.fetch("TRANSACTION_TOTALS_KEY_#{date_range}", expires_in: Settings.eoy_cache_timer.minutes) do
      CURRENCIES.inject({}) do |result, currency|
        result.merge(currency => count_in_currency(currency, date_range))
      end
    end
  end

  def goals(goal)
    ::Donations::Currencies.for([goal]).to_hash
      .map { |k, v| [k, ::Donations::Utils.round_fundraising_goals(v).first] }.to_h
  end

  def count_in_currency(currency = 'USD', date_range = Float::INFINITY..Float::INFINITY)
    count(date_range).reduce(0) do |total, item|
      local_currency, amount = item
      total + ::PaymentProcessor::Currency.convert(amount * 100, currency, local_currency).to_d
    end
  end

  def count(date_range = Float::INFINITY..Float::INFINITY)
    [count_braintree(date_range), count_go_cardless(date_range)].inject do |bt, gc|
      bt.merge(gc) { |_, bt_sum, gc_sum| bt_sum + gc_sum }
    end
  end

  def count_go_cardless(date_range = Float::INFINITY..Float::INFINITY)
    gocardless_transactions
      .where(created_at: date_range)
      .group(:currency)
      .sum(:amount)
  end

  def count_braintree(date_range = Float::INFINITY..Float::INFINITY)
    braintree_transactions
      .where(created_at: date_range)
      .group(:currency)
      .sum(:amount)
  end

  private

  def braintree_transactions
    ::Payment::Braintree::Transaction
      .select(:id, :created_at, :subscription_id, :amount, :currency)
  end

  def gocardless_transactions
    ::Payment::GoCardless::Transaction
      .select(:id, :created_at, :subscription_id, :amount, :currency)
  end
end
