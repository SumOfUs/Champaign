# frozen_string_literal: true

require 'rails_helper'

describe PaymentMethodFetcher do
  let(:member)    { create(:member) }
  let(:customer)  { create(:payment_braintree_customer, member: member) }
  let!(:method_a) { create(:payment_braintree_payment_method, :stored, token: 'a', customer: customer) }
  let!(:method_b) { create(:payment_braintree_payment_method, :stored, token: 'b', customer: customer) }

  formatter = lambda do |m|
    {
      id: m.id,
      last_4: m.last_4,
      instrument_type: m.instrument_type,
      card_type: m.card_type,
      email: m.email,
      token: m.token
    }
  end

  context 'without filter' do
    subject { PaymentMethodFetcher.new(member) }

    it 'fetches all methods without filter' do
      expected = Payment::Braintree::PaymentMethod.all.map(&formatter)

      expect(subject.fetch).to match_array(expected)
    end
  end

  context 'with filter' do
    subject { PaymentMethodFetcher.new(member, filter: ['a']) }

    it 'fetches all methods without filter' do
      expected = [method_a].map(&formatter)

      expect(subject.fetch).to match_array(expected)
    end
  end

  context 'with empty filter' do
    subject { PaymentMethodFetcher.new(member, filter: []) }

    it 'returns empty array' do
      expect(subject.fetch).to match_array([])
    end
  end
end
