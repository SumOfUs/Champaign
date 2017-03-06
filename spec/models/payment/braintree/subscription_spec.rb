# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_subscriptions
#
#  id                   :integer          not null, primary key
#  subscription_id      :string
#  merchant_account_id  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  page_id              :integer
#  amount               :decimal(10, 2)
#  currency             :string
#  action_id            :integer
#  cancelled_at         :datetime
#  customer_id          :string
#  billing_day_of_month :integer
#  payment_method_id    :integer
#

require 'rails_helper'

describe Payment::Braintree::Subscription do
  let(:subscription) { create :payment_braintree_subscription }
  subject { subscription }

  it { is_expected.to respond_to :subscription_id }
  it { is_expected.to respond_to :amount }
  it { is_expected.to respond_to :currency }
  it { is_expected.to respond_to :merchant_account_id }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :page }
  it { is_expected.to respond_to :action }
  it { is_expected.to respond_to :action_id }

  it { is_expected.to_not respond_to :price }
  it { is_expected.to_not respond_to :next_billing_date }

  it 'handles money properly' do
    create :payment_braintree_subscription, amount: 12.41
    create :payment_braintree_subscription, amount: 10_701.11
    expect(Payment::Braintree::Subscription.all.map(&:amount).sum).to eq 10_713.52
    expect(Payment::Braintree::Subscription.last.amount.class).to eq BigDecimal
  end

  describe 'scopes' do
    context 'active' do
      let!(:subscription) { create :payment_braintree_subscription, cancelled_at: nil }
      let!(:cancelled_subscription) { create :payment_braintree_subscription, cancelled_at: 1.month.ago }
      it 'only returns subscriptions that have not been cancelled' do
        expect(Payment::GoCardless::Subscription.active).to match([])
      end
    end
  end

  describe 'publish cancellation event' do
    let(:subscription) { create(:payment_braintree_subscription, subscription_id: 'asd123') }
    it 'pushes to the event queue with correct parameters' do
      expect(ChampaignQueue).to receive(:push).with(type: 'cancel_subscription',
                                                    params: {
                                                      recurring_id: 'asd123',
                                                      canceled_by: 'user'
                                                    })
      subscription.publish_cancellation('user')
    end
  end

  describe 'publish amount update event' do
    let(:subscription) { create(:payment_braintree_subscription, subscription_id: 'asd123', amount: 100) }
    it 'pushes to the event queue with correct parameters' do
      expect(ChampaignQueue).to receive(:push).with(type: 'recurring_payment_update',
                                                    params: {
                                                      recurring_id: 'asd123',
                                                      amount: '100.0'
                                                    })
      subscription.publish_amount_update
    end
  end
end
