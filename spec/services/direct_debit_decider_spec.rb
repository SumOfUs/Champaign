# frozen_string_literal: true
require 'rails_helper'

describe DirectDebitDecider do
  describe 'decide' do
    [:only_recurring, :recurring, :one_off, :garbage_value].each do |recurring_default|
      recurring = (recurring_default == :only_recurring || recurring_default == :recurring)
      context "recurring is '#{recurring_default}'" do
        it 'returns true when country list is just DE' do
          decision = DirectDebitDecider.decide(['DE'], recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when country list is just AT' do
          decision = DirectDebitDecider.decide(['AT'], recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when country list is just ES' do
          decision = DirectDebitDecider.decide(['ES'], recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when country list is DE and GB' do
          decision = DirectDebitDecider.decide(%w(DE GB), recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when country list is DE and several others' do
          decision = DirectDebitDecider.decide(%w(US FR DE IN), recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when DE is a lowercase symbol' do
          decision = DirectDebitDecider.decide([:de], recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when DE is a lowercase string' do
          decision = DirectDebitDecider.decide(['de'], recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when DE is an uppercase symbol' do
          decision = DirectDebitDecider.decide([:DE], recurring_default)
          expect(decision).to eq(true)
        end

        it 'returns true when DE is an uppercase string' do
          decision = DirectDebitDecider.decide(['DE'], recurring_default)
          expect(decision).to eq(true)
        end

        it "returns #{recurring} when country list is GB" do
          decision = DirectDebitDecider.decide(['GB'], recurring_default)
          expect(decision).to eq(recurring)
        end

        it "returns #{recurring} when country list is GB and others" do
          decision = DirectDebitDecider.decide(%w(US FR GB IN), recurring_default)
          expect(decision).to eq(recurring)
        end

        it "returns #{recurring} when country list is NL" do
          decision = DirectDebitDecider.decide(['NL'], recurring_default)
          expect(decision).to eq(recurring)
        end

        it 'returns false when country list is empty' do
          decision = DirectDebitDecider.decide([], recurring_default)
          expect(decision).to eq(false)
        end

        it 'returns false when country is unknown' do
          decision = DirectDebitDecider.decide(['RD', ''], recurring_default)
          expect(decision).to eq(false)
        end

        it 'returns false when country list has no direct debit countries' do
          decision = DirectDebitDecider.decide(%w(US MX GH IN), recurring_default)
          expect(decision).to eq(false)
        end
      end
    end
  end
end
