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
    create :payment_go_cardless_subscription, amount: 10701.11
    expect(Payment::GoCardless::Subscription.all.map(&:amount).sum).to eq 10713.52
    expect(Payment::GoCardless::Subscription.last.amount.class).to eq BigDecimal
  end

  describe 'associations' do
    it 'associates customer with a GoCardless::Customer' do
      expect{ subscription.customer = build :payment_go_cardless_customer }.not_to raise_error
    end

    it 'associates payment_method with a GoCardless::PaymentMethod' do
      expect{ subscription.payment_method = build :payment_go_cardless_payment_method }.not_to raise_error
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
      expect{
        subject.run_create!
      }.to change{ subject.reload.created? }.from(false).to(true)
    end

    it 'can be finished' do
      expect{
        subject.run_finish!
      }.to change{ subject.reload.finished? }.from(false).to(true)
    end

    it 'can be cancelled' do
      expect{
        subject.run_cancel!
      }.to change{ subject.reload.cancelled? }.from(false).to(true)
    end

    it 'can be denied' do
      expect{
        subject.run_deny!
      }.to change{ subject.reload.customer_approval_denied? }.from(false).to(true)
    end

    context 'can be activated' do
      it 'from pending' do
        expect{
          subject.run_approve!
        }.to change{ subject.reload.active? }.from(false).to(true)
      end

      it 'not from finished' do
        subject.run_finish!

        expect{
          subject.run_approve!
        }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "charging" do
      subject { create :payment_go_cardless_subscription }

      let(:event) { {'links' => {'payment' => 'PM1234'}} }
      let(:charger) { double }

      before do
        subject.run_approve!
      end

      it 'calls charge!' do
        expect(
          Payment::GoCardless::Subscription::Charge
        ).to receive(:new).with(subject, event){ charger }

        expect(
          charger
        ).to receive(:call)

        subject.run_payment_create!(event)
      end
    end
  end
end
