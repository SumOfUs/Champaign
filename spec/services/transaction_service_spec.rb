# frozen_string_literal: true

require 'rails_helper'

describe TransactionService do
  around(:each) do |example|
    VCR.use_cassette('money_from_oxr') do
      example.run
    end
  end

  before do
    %w[USD CAD AUD NZD GBP EUR CHF].each do |currency|
      create_list :payment_braintree_transaction, 2, amount: 100, currency: currency, created_at: Date.today
    end

    %w[USD CAD AUD NZD GBP EUR CHF].each do |currency|
      create_list :payment_braintree_transaction, 2, amount: 100, currency: currency, created_at: 2.months.ago
    end

    create_list :payment_go_cardless_transaction, 2, amount: 100, currency: 'EUR', created_at: Date.today
    create_list :payment_go_cardless_transaction, 2, amount: 100, currency: 'EUR', created_at: 2.months.ago
  end

  describe '.count_braintree' do
    let!(:sum_of_all_transactions) { %w[USD CAD AUD NZD GBP EUR CHF].reduce({}) { |h, c| h.merge(c => 400.to_d) } }
    let!(:sum_of_recent_transactions) { %w[USD CAD AUD NZD GBP EUR CHF].reduce({}) { |h, c| h.merge(c => 200.to_d) } }

    it 'counts all braintree transactions grouped by currency' do
      totals = TransactionService.count_braintree
      expect(totals).to include sum_of_all_transactions
    end

    it 'includes subscription charges' do
      %w[USD CAD AUD NZD GBP EUR CHF].each do |currency|
        create :payment_braintree_transaction, :with_subscription, amount: 100, currency: currency
      end
      totals = TransactionService.count_braintree
      expect(totals).to include('EUR' => 500.to_d)
    end

    it 'accepts a date range' do
      totals = TransactionService.count_braintree 1.month.ago..Date.today
      expect(totals).to include sum_of_recent_transactions
    end
  end

  describe '.count_go_cardless' do
    it 'counts all gocardless transactions grouped by currency' do
      totals = TransactionService.count_go_cardless
      expect(totals).to include('EUR' => 400.to_d)
    end

    it 'includes subscription charges' do
      %w[AUD GBP EUR].each do |currency|
        create :payment_go_cardless_transaction, :with_subscription, amount: 100, currency: currency
      end
      totals = TransactionService.count_go_cardless
      expect(totals).to include('EUR' => 500.to_d)
    end

    it 'accepts a date range' do
      totals = TransactionService.count_go_cardless 1.month.ago..Date.today
      expect(totals).to include('EUR' => 200.to_d)
    end
  end

  describe '.count' do
    it 'aggregates GoCardless and Braintree transactions' do
      expected = { 'EUR' => 800.to_d, 'AUD' => 400.to_d }
      expect(TransactionService.count).to include expected
    end
  end

  describe '.count_in_currency' do
    it 'converts .count totals to a currency and returns a total' do
      # default is USD
      expect(TransactionService.count_in_currency).to be_within(500).of(3000)
      expect(TransactionService.count_in_currency('GBP')).to be_within(500).of(2200)
    end
  end

  describe '.totals' do
    it 'returns the total count in all supported currencies' do
      expect(TransactionService.totals).to include(*TransactionService::CURRENCIES)
    end
  end
end
