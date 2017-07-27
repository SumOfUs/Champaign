# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_subscriptions
#
#  id                :integer          not null, primary key
#  go_cardless_id    :string
#  amount            :decimal(, )
#  currency          :string
#  status            :integer
#  name              :string
#  payment_reference :string
#  page_id           :integer
#  action_id         :integer
#  payment_method_id :integer
#  customer_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  aasm_state        :string
#  cancelled_at      :datetime
#

require 'rails_helper'

describe Payment::GoCardless::Subscription do
  let(:subscription) { build :payment_go_cardless_subscription }
  subject { subscription }

  it { is_expected.to respond_to :go_cardless_id }
  it { is_expected.to respond_to :amount }
  it { is_expected.to respond_to :currency }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  # Associations
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :page }
  it { is_expected.to respond_to :action }
  it { is_expected.to respond_to :action_id }
  it { is_expected.to respond_to :payment_method }
  it { is_expected.to respond_to :payment_method_id }
  it { is_expected.to respond_to :customer }
  it { is_expected.to respond_to :customer_id }

  # Fields passed back from GoCardless that we don't record
  it { is_expected.not_to respond_to :start_date }
  it { is_expected.not_to respond_to :end_date }
  it { is_expected.not_to respond_to :interval }
  it { is_expected.not_to respond_to :interval_unit }
  it { is_expected.not_to respond_to :day_of_month }
  it { is_expected.not_to respond_to :month }

  it 'handles amount as BigDecimal' do
    create :payment_go_cardless_subscription, amount: 12.41
    create :payment_go_cardless_subscription, amount: 10_701.11
    expect(Payment::GoCardless::Subscription.all.map(&:amount).sum).to eq 10_713.52
    expect(Payment::GoCardless::Subscription.last.amount.class).to eq BigDecimal
  end

  describe 'associations' do
    it 'associates customer with a GoCardless::Customer' do
      expect { subscription.customer = build :payment_go_cardless_customer }.not_to raise_error
    end

    it 'associates payment_method with a GoCardless::PaymentMethod' do
      expect { subscription.payment_method = build :payment_go_cardless_payment_method }.not_to raise_error
    end
  end

  describe 'validation' do
    before :each do
      expect(subscription).to be_valid
    end

    it 'rejects blank go_cardless_id' do
      subscription.go_cardless_id = ''
      expect(subscription).to be_invalid
    end
  end

  describe 'state' do
    subject { create :payment_go_cardless_subscription }

    it 'has initial state' do
      expect(subject.pending?).to be(true)
    end

    it 'can be created' do
      expect do
        subject.run_create!
      end.to change { subject.reload.created? }.from(false).to(true)
    end

    it 'can be finished' do
      expect do
        subject.run_finish!
      end.to change { subject.reload.finished? }.from(false).to(true)
    end

    it 'can be cancelled' do
      expect do
        subject.run_cancel!
      end.to change { subject.reload.cancelled? }.from(false).to(true)
    end

    it 'can be denied' do
      expect do
        subject.run_deny!
      end.to change { subject.reload.customer_approval_denied? }.from(false).to(true)
    end

    context 'can be activated' do
      it 'from pending' do
        expect do
          subject.run_approve!
        end.to change { subject.reload.active? }.from(false).to(true)
      end

      it 'not from finished' do
        subject.run_finish!

        expect do
          subject.run_approve!
        end.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'charging' do
      subject { create :payment_go_cardless_subscription }

      let(:event) { { 'links' => { 'payment' => 'PM1234' } } }
      let(:charger) { double }

      before do
        subject.run_approve!
      end

      it 'calls charge!' do
        expect(
          Payment::GoCardless::Subscription::Charge
        ).to receive(:new).with(subject, event) { charger }

        expect(
          charger
        ).to receive(:call)

        subject.run_payment_create!(event)
      end
    end
  end

  describe 'scopes' do
    context 'active' do
      let!(:subscription) { create :payment_go_cardless_subscription, cancelled_at: nil }
      let!(:cancelled_subscription) { create :payment_go_cardless_subscription, cancelled_at: 1.month.ago }
      it 'only returns subscriptions that have not been cancelled' do
        expect(Payment::GoCardless::Subscription.active).to match([subscription])
      end
    end
  end

  describe 'publish cancellation event' do
    let(:subscription) { create(:payment_go_cardless_subscription, go_cardless_id: 'adklwe') }
    it 'pushes to the event queue with correct parameters' do
      expect(ChampaignQueue).to receive(:push).with(
        { type: 'cancel_subscription',
          params: {
            recurring_id: 'adklwe',
            canceled_by: 'user'
          } },
        { group_id: "gocardless-subscription:#{subscription.id}" }
      )
      subscription.publish_cancellation('user')
    end
  end
end
