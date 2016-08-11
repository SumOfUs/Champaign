require 'rails_helper'

describe 'API::Stateless Subscriptions' do
  include Requests::JsonHelpers
  include AuthToken
  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_braintree_customer, member: member) }
  let!(:subscription) { create(:payment_braintree_subscription, customer: customer) }
  let!(:subscription_transaction) { create(:payment_braintree_transaction, subscription: subscription, customer: customer ) }
  let!(:standalone_transaction_a) { create(:payment_braintree_transaction, customer: customer ) }
  let!(:standalone_transaction_b) { create(:payment_braintree_transaction, customer: customer ) }

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns a list of stand-alone transactions for member' do
      get '/api/stateless/braintree/transactions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash).to include({
        id: standalone_transaction_a.id,
        status: standalone_transaction_a.status,
        amount: standalone_transaction_a.amount,
        created_at: standalone_transaction_a.created_at
      }.as_json)
      expect(json_hash).to include({
        id: standalone_transaction_b.id,
        status: standalone_transaction_b.status,
        amount: standalone_transaction_b.amount,
        created_at: standalone_transaction_b.created_at
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



