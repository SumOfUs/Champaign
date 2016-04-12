require 'rails_helper'

describe Payment::GoCardless::PaymentMethod do

  subject(:payment_method) { build :payment_go_cardless_payment_method }

  it { is_expected.to respond_to :go_cardless_id }
  it { is_expected.to respond_to :reference }
  it { is_expected.to respond_to :scheme }
  it { is_expected.to respond_to :next_possible_charge_date }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  # Associations
  it { is_expected.to respond_to :customer }
  it { is_expected.to respond_to :customer_id }

  describe 'associations' do
    it 'associates customer with a GoCardless::Customer' do
      expect{ payment_method.customer = build :payment_go_cardless_customer }.not_to raise_error
    end
  end

  describe 'validation' do
    before :each do
      expect(payment_method).to be_valid
    end

    it 'rejects blank go_cardless_id' do
      payment_method.go_cardless_id = ''
      expect(payment_method).to be_invalid
    end
  end

  describe 'state' do
    subject { create :payment_go_cardless_payment_method }

    it 'has initial state' do
      expect(subject.pending?).to be(true)
    end

    it 'can be created' do
      expect{
        subject.has_been_created!
      }.to change{ subject.reload.created? }.from(false).to(true)
    end

    context 'can be submitted' do
      it 'from pending' do
        expect{
          subject.has_been_submitted!
        }.to change{ subject.reload.submitted? }.from(false).to(true)
      end

      it 'from created' do
        subject.has_been_created!

        expect{
          subject.has_been_submitted!
        }.to change{ subject.reload.submitted? }.from(false).to(true)
      end
    end

    context 'can be activated' do
      it 'from pending' do
        expect{
          subject.has_been_activated!
        }.to change{ subject.reload.active? }.from(false).to(true)
      end

      it 'from created' do
        subject.has_been_created!

        expect{
          subject.has_been_activated!
        }.to change{ subject.reload.active? }.from(false).to(true)
      end

      it 'from submitted' do
        subject.has_been_submitted!

        expect{
          subject.has_been_activated!
        }.to change{ subject.reload.active? }.from(false).to(true)
      end
    end

    it 'can be cancelled' do
      subject.has_been_activated!

      expect{
        subject.has_been_cancelled!
      }.to change{ subject.reload.cancelled? }.from(false).to(true)
    end
  end
end
