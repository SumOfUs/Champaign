# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_transactions
#
#  id                      :integer          not null, primary key
#  transaction_id          :string
#  transaction_type        :string
#  transaction_created_at  :datetime
#  payment_method_token    :string
#  customer_id             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  merchant_account_id     :string
#  currency                :string
#  page_id                 :integer
#  payment_instrument_type :string
#  status                  :integer
#  amount                  :decimal(10, 2)
#  processor_response_code :string
#  payment_method_id       :integer
#  subscription_id         :integer
#

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
    create :payment_braintree_transaction, amount: 10_701.11
    expect(Payment::Braintree::Transaction.all.map(&:amount).sum).to eq 10_713.52
    expect(Payment::Braintree::Transaction.last.amount.class).to eq BigDecimal
  end

  describe 'subscription' do
    let(:subscription) { create(:payment_braintree_subscription) }

    it 'can belong to a subscription' do
      transaction = subscription.transactions.create
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
      transaction.update_attributes(status: :success)
      expect(transaction.reload.status).to eq 'success'
      transaction.update_attributes(status: :failure)
      expect(transaction.reload.status).to eq 'failure'
    end

    it 'has ! setters' do
      transaction.failure!
      expect(transaction.reload.status).to eq 'failure'
      transaction.success!
      expect(transaction.reload.status).to eq 'success'
    end
  end

  describe 'one-off' do
    let!(:transaction_with_subscription) { create(:payment_braintree_transaction, subscription_id: 123) }
    let!(:transaction_without_subscription) { create(:payment_braintree_transaction, subscription_id: nil) }

    it 'returns transactions without a subscription' do
      expect(Payment::Braintree::Transaction.one_off).to match_array([transaction_without_subscription])
    end
  end

  describe 'publish subscription payment' do
    let(:action) { create(:action, form_data: { 'subscription_id' => 'subscription_id' }) }
    let(:subscription) { create(:payment_braintree_subscription, subscription_id: 'subscription_id', action: action) }
    let!(:transaction) { create(:payment_braintree_transaction, subscription: subscription, status: 'success') }
    it 'pushes a subscription payment event with a status to the queue' do
      expected_payload = {
        type: 'subscription-payment',
        params: {
          created_at: transaction.created_at,
          recurring_id: 'subscription_id',
          success: 1,
          status: 'completed'
        }
      }
      expect(ChampaignQueue).to receive(:push).with(expected_payload, delay: 120)
      transaction.publish_subscription_charge
    end
  end
end
