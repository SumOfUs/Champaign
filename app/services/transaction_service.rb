# frozen_string_literal: true

module TransactionService
  extend self

  def count_in_usd(date_range = Float::INFINITY..Float::INFINITY)
    count(date_range).reduce(0) do |total, item|
      currency, amount = item
      total + ::PaymentProcessor::Currency.convert(amount, 'USD', currency).to_d
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
      .where(subscription_id: nil)
  end

  def gocardless_transactions
    ::Payment::GoCardless::Transaction
      .select(:id, :created_at, :subscription_id, :amount, :currency)
      .where(subscription_id: nil)
  end
end
