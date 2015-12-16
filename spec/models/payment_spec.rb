require 'rails_helper'

describe Payment do
  describe '.customer' do
    it 'returns customer with matching email' do
      member = create(:member, email: 'foo@example.com')
      create(:payment_braintree_customer, member: member)

      expect(
        Payment.customer('foo@example.com')
      ).to be_a Payment::BraintreeCustomer
    end
  end

  describe 'write_successful_transaction' do
    let(:builder) { double }

    before do
      allow(Payment::BraintreeTransactionBuilder).to receive(:build){ builder }
    end

    it 'requires a transaction' do
      expect{ Payment.write_successful_transaction }.to raise_error(
        ArgumentError, 'missing keywords: action, transaction_response'
      )
    end

    it 'delegates to transaction builder' do
      expect(Payment::BraintreeTransactionBuilder).to receive(:build).with('action', 'transaction')

      Payment.write_successful_transaction({action: 'action', transaction_response: 'transaction'})
    end
  end

  describe Payment::BraintreeTransactionBuilder do
    let(:sale) do
      double(:sale, {
        id: '1',
        type: 'sale',
        amount: 100.00,
        created_at: Time.now
      })
    end

    let(:card) do
      double(:card, {
        card_type: 'debit',
        bin: '123',
        cardholder_name: 'bob',
        debit: 'yes',
        last_4: '1234',
        token: 'anx'
      })
    end

    let(:customer_details) do
      double(:customer_details, {
        email: 'foo@example.com',
        first_name: "foo",
        last_name: '',
        id: 'fe2'
      })

      let(:transaction) do
        double(:transaction, {
          credit_card_details: card,
          customer_details: customer_details,
          transaction: sale
        })
      end

      subject { Payment::BraintreeTransactionBuilder.build(transaction) }

      context "without existing customer" do
        it 'creates transaction' do

        end
      end
    end
  end
end
