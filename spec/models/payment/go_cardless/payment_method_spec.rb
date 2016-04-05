require 'rails_helper'

describe Payment::GoCardless::PaymentMethod do

  let(:payment_method) { build :payment_go_cardless_payment_method }
  subject { payment_method }

  it { is_expected.to respond_to :go_cardless_id }
  it { is_expected.to respond_to :status }
  it { is_expected.to respond_to :reference }
  it { is_expected.to respond_to :scheme }
  it { is_expected.to respond_to :next_possible_charge_date }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  # Associations
  it { is_expected.to respond_to :customer }
  it { is_expected.to respond_to :customer_id }

  describe 'validation' do
    before :each do
      expect(payment_method).to be_valid
    end

    it 'rejects nil status' do
      payment_method.status = nil
      expect(payment_method).to be_invalid
    end

    it 'rejects blank go_cardless_id' do
      payment_method.go_cardless_id = ''
      expect(payment_method).to be_invalid
    end
  end

  describe 'status' do

    it 'can be set to "pending_submission"' do
      payment_method.status = "pending_submission"
      expect(payment_method.pending_submission?).to eq true
    end

    it 'can be set to "submitted"' do
      payment_method.status = "submitted"
      expect(payment_method.submitted?).to eq true
    end

    it 'can be set to "active"' do
      payment_method.status = "active"
      expect(payment_method.active?).to eq true
    end

    it 'can be set to "failed"' do
      payment_method.status = "failed"
      expect(payment_method.failed?).to eq true
    end

    it 'can be set to "cancelled"' do
      payment_method.status = "cancelled"
      expect(payment_method.cancelled?).to eq true
    end

    it 'can be set to "expired"' do
      payment_method.status = "expired"
      expect(payment_method.expired?).to eq true
    end
  end
end
