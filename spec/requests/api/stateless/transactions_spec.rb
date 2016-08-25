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
    customer: customer,
    payment_method: payment_method) }
  let!(:subscription_transaction) { create(:payment_braintree_transaction,
    subscription: subscription,
    customer: customer,
    payment_method: payment_method) }
  let!(:standalone_transaction_a) { create(:payment_braintree_transaction,
    customer: customer,
    payment_method: payment_method,
    amount: 100,
    status: 'failure') }
  let!(:standalone_transaction_b) { create(:payment_braintree_transaction,
    customer: customer,
    amount: 50,
    status: 'success',
    payment_method: payment_method ) }

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns a list of stand-alone transactions with their payment methods for member' do
      get '/api/stateless/braintree/transactions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash).to include({
        id: standalone_transaction_a.id,
        status: 'failure',
        amount: '100.0',
        created_at: standalone_transaction_a.created_at,
        payment_method: {
          instrument_type: 'credit card',
          token: '2ewruo4i5o3',
          last_4: '2454',
          expiration_date: nil,
          bin: nil,
          email: customer.email,
          card_type: 'Mastercard'
        }
      }.as_json)
      expect(json_hash).to include({
        id: standalone_transaction_b.id,
        status: 'success',
        amount: '50.0',
        created_at: standalone_transaction_b.created_at,
        payment_method: {
          instrument_type: 'credit card',
          token: '2ewruo4i5o3',
          last_4: '2454',
          expiration_date: nil,
          bin: nil,
          email: customer.email,
          card_type: 'Mastercard'
        }
      }.as_json)
    end

    it 'does not list transactions that are associated with subscriptions' do
      get '/api/stateless/braintree/transactions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash).to_not include({
        id: subscription_transaction.id,
        status: subscription_transaction.status,
        amount: subscription_transaction.amount,
        created_at: subscription_transaction.created_at
      }.as_json)
    end

  end
end
