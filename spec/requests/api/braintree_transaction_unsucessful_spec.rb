require 'rails_helper'

describe "Braintree API" do
  let(:page) { create(:page) }
  let(:form) { create(:form) }

  let(:user) do
    {
      form_id:  form.id,
      name:     'bob fischer',
      email:    'bob@example.com',
      postal:   '12345',
      address1: 'Lynda Vista',
      country:  'US'
    }
  end

  let(:params) do
    {
      currency:   'EUR',
      amount:     '1.00',
      recurring:  false,
      payment_method_nonce: 'fake-valid-nonce',
      user: user
    }
  end

  before :each do
    allow(ChampaignQueue).to receive(:push)
  end

  subject{ post(api_braintree_transaction_path(page.id), params) }

  describe "Invalid Currency" do
    before do
      params[:currency] = 'JPN'
    end

    it 'raises' do
     expect{
        VCR.use_cassette("transaction not handled currency") do
          subject
        end
      }.to raise_error(PaymentProcessor::Exceptions::InvalidCurrency)
    end
  end

  describe "Processer Declined" do
    before do
      params[:amount] = '2000.0'

      VCR.use_cassette("transaction processor declined") do
        subject
      end
    end

    it 'pushes nothing to the queue' do
      expect(ChampaignQueue).not_to receive(:push)
    end

    describe 'response' do
      it 'http code is 422' do
        expect(response.code).to eq("422")
      end

      it 'has message' do
        expected_response_body = {
          success: false,
          errors: [{declined: true, code: '2000', message: 'Do Not Honor'}]
        }

        expect(response.body).to eq(expected_response_body.to_json)
      end
    end

    describe 'stores tranasction locally' do
      let(:transaction) { Payment::BraintreeTransaction.first }

      it 'stores single transaction' do
        expect(Payment::BraintreeTransaction.count).to eq(1)
      end

      describe 'attributes' do
        it 'processor response code' do
          expect(transaction.processor_response_code).to eq('2000')
        end

        it 'status' do
          expect(transaction.status).to eq('failure')
        end
      end
    end

    describe 'does not store locally' do
      it 'member' do
        expect(Member.count).to eq(0)
      end

      it 'subscription' do
        expect(Payment::BraintreeSubscription.count).to eq(0)
      end

      it 'customer' do
        expect(Payment::BraintreeCustomer.count).to eq(0)
      end
    end
  end
end

