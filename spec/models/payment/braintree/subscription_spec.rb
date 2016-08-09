# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_subscriptions
#
#  id                  :integer          not null, primary key
#  subscription_id     :string
#  merchant_account_id :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  page_id             :integer
#  amount              :decimal(10, 2)
#  currency            :string
#  action_id           :integer
#  cancelled_at        :datetime
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
end
