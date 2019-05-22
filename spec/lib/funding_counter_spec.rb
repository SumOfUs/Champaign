# frozen_string_literal: true

require 'rails_helper'

describe 'FundingCounter' do
  let(:page) { create(:page, total_donations: 10_000.00) }

  describe 'money_conversions' do
    let(:record) { FundingCounter.new(page, 'USD', 20) }

    it 'should calculate original_amount' do
      expect(record.original_amount.to_f).to eql 100.0
    end

    it 'should calculate converted_amount' do
      expect(record.converted_amount.to_f).to eql 20.0
    end
  end

  describe '.update' do
    before do
      FundingCounter.new(page, 'USD', 20).update
    end

    it 'should increment page donations by 20' do
      page.reload
      expect(page.total_donations.to_f).to eql 12_000.0
    end
  end

  describe '.update' do
    before do
      FundingCounter.new(page, 'USD', -10).update
    end

    it 'should reduce page donations by 10' do
      page.reload
      expect(page.total_donations.to_f).to eql 9_000.0
    end
  end
end
