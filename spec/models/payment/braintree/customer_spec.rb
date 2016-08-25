# frozen_string_literal: true
require 'rails_helper'

describe Payment::Braintree::Customer do
  describe '#member' do
    let(:member)   { create(:member) }
    let(:customer) { create(:payment_braintree_customer) }

    before do
      customer.update(member: member)
    end

    it 'returns the associated member' do
      expect(customer.member).to eq(member)
    end
  end
end
