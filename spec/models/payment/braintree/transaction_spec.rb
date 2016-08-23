# frozen_string_literal: true
require 'rails_helper'

describe Payment::Braintree::Transaction do
  let(:transaction) { create :payment_braintree_transaction }
  subject { transaction }

  it { is_expected.to respond_to :transaction_id }
  it { is_expected.to respond_to :transaction_type }
  it { is_expected.to respond_to :amount }
  it { is_expected.to respond_to :transaction_created_at }
  it { is_expected.to respond_to :payment_method }
  it { is_expected.to respond_to :customer_id }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }
  it { is_expected.to respond_to :merchant_account_id }
  it { is_expected.to respond_to :currency }
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :page }
  it { is_expected.to respond_to :payment_instrument_type }
  it { is_expected.to respond_to :status }
  it { is_expected.to respond_to :success? }
  it { is_expected.to respond_to :failure? }

  it 'handles money properly' do
    create :payment_braintree_transaction, amount: 12.41
    create :payment_braintree_transaction, amount: 10701.11
    expect(Payment::Braintree::Transaction.all.map(&:amount).sum).to eq 10713.52
    expect(Payment::Braintree::Transaction.last.amount.class).to eq BigDecimal
  end

  describe 'subscription' do
    let(:subscription) { create(:payment_braintree_subscription) }

    it 'can belong to a subscription' do
      transaction = subscription.transactions.create()
      subscription.transactions
      expect(transaction.reload.subscription).to eq(subscription)
      expect(subscription.transactions).to eq([transaction])
    end
  end

  describe '#status' do
    it 'can be set with a string' do
      transaction.status = 'failure'
      expect(transaction.success?).to eq false
      expect(transaction.failure?).to eq true
      transaction.status = 'success'
      expect(transaction.success?).to eq true
      expect(transaction.failure?).to eq false
    end

    it 'can read out a string' do
      transaction.update_attributes(:status => :success)
      expect(transaction.reload.status).to eq 'success'
      transaction.update_attributes(:status => :failure)
      expect(transaction.reload.status).to eq 'failure'
    end

    it 'has ! setters' do
      transaction.failure!
      expect(transaction.reload.status).to eq 'failure'
      transaction.success!
      expect(transaction.reload.status).to eq 'success'
    end
  end
end
