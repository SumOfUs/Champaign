require 'rails_helper'

describe 'API::Stateless Subscriptions' do
  include Requests::RequestHelpers
  include AuthToken

  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_braintree_customer, member: member) }
  let!(:payment_method) { create(:braintree_payment_method,
    customer: customer,
    instrument_type: 'credit card',
    token: '2ewruo4i5o3',
    last_4: '2454',
    email: customer.email,
    card_type: 'Mastercard')}

  let!(:subscription) { create(:payment_braintree_subscription,
    id: 1234,
    customer: customer,
    payment_method: payment_method,
    amount: 4,
    billing_day_of_month: 22,
    created_at: Time.now) }
  let!(:transaction_a) { create(:payment_braintree_transaction,
    subscription: subscription,
    status: 'failure',
    amount: 100) }
  let!(:transaction_b) { create(:payment_braintree_transaction,
    subscription: subscription,
    status: 'success',
    amount: 200) }

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns subscriptions with its nested transactions and payment method for member' do
      get '/api/stateless/braintree/subscriptions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.first.keys).to include("id", "billing_day_of_month", "created_at", "amount", "transactions", "payment_method")
      expect(json_hash.first['id']).to eq(1234)
      expect(json_hash.first['created_at']).to match(/^\d{4}-\d{2}-\d{2}/)
      expect(json_hash.first['billing_day_of_month']).to eq 22
      expect(json_hash.first['amount']).to eq '4.0'

      expect(json_hash.first['payment_method']).to match({
        id: payment_method.id,
        instrument_type: 'credit card',
        token: '2ewruo4i5o3',
        last_4: '2454',
        expiration_date: nil,
        bin: nil,
        email: customer.email,
        card_type: 'Mastercard'}.as_json)

      expect(json_hash.first['transactions']).to include({
        id: transaction_a.id,
        status: 'failure',
        amount: '100.0',
        created_at: transaction_a.created_at
      }.as_json)

      expect(json_hash.first["transactions"]).to include({
        id: transaction_b.id,
        status: 'success',
        amount: '200.0',
        created_at: transaction_b.created_at
      }.as_json)
    end
  end

  describe 'DELETE destroy' do
    let!(:cancel_this_subscription) { create(:payment_braintree_subscription, subscription_id: "4ts4r2", customer: customer) }
    let!(:no_such_subscription) { create(:payment_braintree_subscription, subscription_id: "nosuchthing", customer: customer) }

    it 'deletes the subscription locally and on Braintree' do
      VCR.use_cassette("stateless api cancel subscription") do
        delete "/api/stateless/braintree/subscriptions/#{cancel_this_subscription.id}", nil, auth_headers
        expect(response.status).to eq(200)
        expect {::Payment::Braintree::Subscription.find(cancel_this_subscription.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    it 'returns success and deletes the subscription locally even if does not exist on Braintree' do
      VCR.use_cassette("stateless api cancel subscription failure") do
        delete "/api/stateless/braintree/subscriptions/#{no_such_subscription.id}", nil, auth_headers
        expect(response.status).to eq(200)
        expect {::Payment::Braintree::Subscription.find(no_such_subscription.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end

    end
  end
end
