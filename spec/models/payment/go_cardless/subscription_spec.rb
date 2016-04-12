require 'rails_helper'

describe Payment::GoCardless::Subscription do

  let(:subscription) { build :payment_go_cardless_subscription }
  subject { subscription }

  it { is_expected.to respond_to :go_cardless_id }
  it { is_expected.to respond_to :amount }
  it { is_expected.to respond_to :currency }
  it { is_expected.to respond_to :status }
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

    it 'rejects nil status' do
      subscription.status = nil
      expect(subscription).to be_invalid
    end

    it 'rejects blank go_cardless_id' do
      subscription.go_cardless_id = ''
      expect(subscription).to be_invalid
    end
  end

  describe 'status' do

    it 'can be set to "pending_customer_approval"' do
      subscription.status = "pending_customer_approval"
      expect(subscription.pending_customer_approval?).to eq true
    end

    it 'can be set to "customer_approval_denied"' do
      subscription.status = "customer_approval_denied"
      expect(subscription.customer_approval_denied?).to eq true
    end

    it 'can be set to "active"' do
      subscription.status = "active"
      expect(subscription.active?).to eq true
    end

    it 'can be set to "finished"' do
      subscription.status = "finished"
      expect(subscription.finished?).to eq true
    end

    it 'can be set to "cancelled"' do
      subscription.status = "cancelled"
      expect(subscription.cancelled?).to eq true
    end
  end
end
