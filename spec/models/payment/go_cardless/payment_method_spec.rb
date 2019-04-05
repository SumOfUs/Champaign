# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_payment_methods
#
#  id                        :integer          not null, primary key
#  aasm_state                :string
#  cancelled_at              :datetime
#  next_possible_charge_date :date
#  reference                 :string
#  scheme                    :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_id               :integer
#  go_cardless_id            :string
#
# Indexes
#
#  index_payment_go_cardless_payment_methods_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => payment_go_cardless_customers.id)
#

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
      expect { payment_method.customer = build :payment_go_cardless_customer }.not_to raise_error
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
      expect do
        subject.run_create!
      end.to change { subject.reload.created? }.from(false).to(true)
    end

    context 'can be submitted' do
      it 'from pending' do
        expect do
          subject.run_submit!
        end.to change { subject.reload.submitted? }.from(false).to(true)
      end

      it 'from created' do
        subject.run_create!

        expect do
          subject.run_submit!
        end.to change { subject.reload.submitted? }.from(false).to(true)
      end
    end

    context 'can be activated' do
      it 'from pending' do
        expect do
          subject.run_activate!
        end.to change { subject.reload.active? }.from(false).to(true)
      end

      it 'from created' do
        subject.run_create!

        expect do
          subject.run_activate!
        end.to change { subject.reload.active? }.from(false).to(true)
      end

      it 'from submitted' do
        subject.run_submit!

        expect do
          subject.run_activate!
        end.to change { subject.reload.active? }.from(false).to(true)
      end
    end

    it 'can be cancelled' do
      subject.run_activate!

      expect do
        subject.run_cancel!
      end.to change { subject.reload.cancelled? }.from(false).to(true)
    end
  end

  describe 'scope' do
    context 'active' do
      let!(:active_method) { create(:payment_go_cardless_payment_method, cancelled_at: nil) }
      let!(:cancelled_method) { create(:payment_go_cardless_payment_method, cancelled_at: Time.now) }

      it 'returns payment methods that have not been cancelled' do
        expect(Payment::GoCardless::PaymentMethod.active).to match([active_method])
      end
    end
  end
end
