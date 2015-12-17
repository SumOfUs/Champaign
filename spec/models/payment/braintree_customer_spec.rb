require 'rails_helper'

describe Payment::BraintreeCustomer do
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
