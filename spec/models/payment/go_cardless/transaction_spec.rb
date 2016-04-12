require 'rails_helper'

describe Payment::GoCardless::Transaction do

  let(:transaction) { build :payment_go_cardless_transaction }
  subject { transaction }

  it { is_expected.to respond_to :go_cardless_id }
  it { is_expected.to respond_to :amount }
  it { is_expected.to respond_to :currency }
  it { is_expected.to respond_to :status }
  it { is_expected.to respond_to :charge_date }
  it { is_expected.to respond_to :amount_refunded }
  it { is_expected.to respond_to :reference }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  # Associations
  it { is_expected.to respond_to :page }
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :action }
  it { is_expected.to respond_to :action_id }
  it { is_expected.to respond_to :payment_method }
  it { is_expected.to respond_to :payment_method_id }
  it { is_expected.to respond_to :customer }
  it { is_expected.to respond_to :customer_id }

  it 'handles amount as BigDecimal' do
    create :payment_go_cardless_transaction, amount: 12.41
    create :payment_go_cardless_transaction, amount: 10701.11
    expect(Payment::GoCardless::Transaction.all.map(&:amount).sum).to eq 10713.52
    expect(Payment::GoCardless::Transaction.last.amount.class).to eq BigDecimal
  end

  it 'handles amount_refunded as BigDecimal' do
    create :payment_go_cardless_transaction, amount_refunded: 12.51
    create :payment_go_cardless_transaction, amount_refunded: 10701.11
    expect(Payment::GoCardless::Transaction.all.map(&:amount_refunded).sum).to eq 10713.62
    expect(Payment::GoCardless::Transaction.last.amount.class).to eq BigDecimal
  end

  describe 'associations' do
    it 'associates customer with a GoCardless::Customer' do
      expect{ transaction.customer = build :payment_go_cardless_customer }.not_to raise_error
    end

    it 'associates payment_method with a GoCardless::PaymentMethod' do
      expect{ transaction.payment_method = build :payment_go_cardless_payment_method }.not_to raise_error
    end
  end

  describe 'validation' do
    before :each do
      expect(transaction).to be_valid
    end

    it 'rejects nil status' do
      transaction.status = nil
      expect(transaction).to be_invalid
    end

    it 'rejects blank go_cardless_id' do
      transaction.go_cardless_id = ''
      expect(transaction).to be_invalid
    end
  end

  describe 'status' do

    it 'can be set to "pending_customer_approval"' do
      transaction.status = "pending_customer_approval"
      expect(transaction.pending_customer_approval?).to eq true
    end

    it 'can be set to pending_submission"' do
      transaction.status = "pending_submission"
      expect(transaction.pending_submission?).to eq true
    end

    it 'can be set to "submitted"' do
      transaction.status = "submitted"
      expect(transaction.submitted?).to eq true
    end

    it 'can be set to "confirmed"' do
      transaction.status = "confirmed"
      expect(transaction.confirmed?).to eq true
    end

    it 'can be set to "paid_out"' do
      transaction.status = "paid_out"
      expect(transaction.paid_out?).to eq true
    end

    it 'can be set to cancelled"' do
      transaction.status = "cancelled"
      expect(transaction.cancelled?).to eq true
    end

    it 'can be set to "customer_approval_denied"' do
      transaction.status = "customer_approval_denied"
      expect(transaction.customer_approval_denied?).to eq true
    end

    it 'can be set to "failed"' do
      transaction.status = "failed"
      expect(transaction.failed?).to eq true
    end

    it 'can be set to "charged_back"' do
      transaction.status = "charged_back"
      expect(transaction.charged_back?).to eq true
    end
  end
end
