# frozen_string_literal: true
require 'rails_helper'

describe BraintreeServices::PaymentOptions do
  let(:member) { create(:member, email: 'test@example.com') }

  let(:params) do
    {
      user: {
        email: 'test@example.com'
      },
      payment: {
        payment_method_id: payment_method.id
      }
    }
  end

  describe '#last_4' do
    let(:customer) { create(:payment_braintree_customer, member: member) }

    context 'with paypal' do
      let(:payment_method) { create(:payment_braintree_payment_method, :paypal, customer: customer) }

      it 'returns PYPL' do
        expect(
          described_class.new(params, false).last_4
        ).to eq('PYPL')
      end
    end

    context 'with credit card' do
      let(:payment_method) { create(:payment_braintree_payment_method, customer: customer) }

      it 'returns last 4 digits' do
        expect(
          described_class.new(params, false).last_4
        ).to eq('1234')
      end
    end
  end
end
