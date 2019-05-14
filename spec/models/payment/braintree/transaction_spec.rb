# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_braintree_transactions
#
#  id                      :integer          not null, primary key
#  amount                  :decimal(10, 2)
#  amount_refunded         :decimal(8, 2)
#  currency                :string
#  payment_instrument_type :string
#  payment_method_token    :string
#  processor_response_code :string
#  refund                  :boolean          default(FALSE)
#  refunded_at             :datetime
#  status                  :integer
#  transaction_created_at  :datetime
#  transaction_type        :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  customer_id             :string
#  merchant_account_id     :string
#  page_id                 :integer
#  payment_method_id       :integer
#  refund_transaction_id   :string
#  subscription_id         :integer
#  transaction_id          :string
#
# Indexes
#
#  braintree_payment_method_index                   (payment_method_id)
#  braintree_transaction_subscription               (subscription_id)
#  index_payment_braintree_transactions_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
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
    let!(:transaction) do
      create(:payment_braintree_transaction,
             subscription: subscription,
             transaction_id: 't7297',
             status: 'success',
             amount: 123)
    end
    it 'pushes a subscription payment event with a status to the queue' do
      expected_payload = {
        type: 'subscription-payment',
        params: {
          # Matches the only string format AK accepts, e.g. "2016-12-22 17:47:42"
          created_at: /\A\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}\z/,
          recurring_id: 'subscription_id',
          success: 1,
          status: 'completed',
          amount: '123.0',
          trans_id: 't7297'
        }
      }
      expect(ChampaignQueue).to receive(:push).with(
        expected_payload,
        group_id: "braintree-subscription:#{subscription.id}"
      )
      transaction.publish_subscription_charge
    end
  end
end
