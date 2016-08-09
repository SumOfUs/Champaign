require 'rails_helper'

describe 'API::Stateless PaymentMethods' do
  include Requests::JsonHelpers
  include AuthToken
  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_braintree_customer, member: member) }
  let!(:subscription) { create(:payment_braintree_subscription, customer: customer) }
  let!(:transaction_a) { create(:payment_braintree_transaction, subscription: subscription ) }
  let!(:transaction_b) { create(:payment_braintree_transaction, subscription: subscription ) }

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns subscriptions for member' do
      get '/api/stateless/braintree/subscriptions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.first.keys).to include("id", "billing_day_of_month", "created_at", "amount", "transactions")
      expect(json_hash.first)
      expect(json_hash.first["transactions"]).to include({
        id: transaction_a.id,
        status: transaction_a.status,
        amount: transaction_a.amount,
        created_at: transaction_a.created_at
      }.as_json)
      expect(json_hash.first["transactions"]).to include({
        id: transaction_b.id,
        status: transaction_b.status,
        amount: transaction_b.amount,
        created_at: transaction_b.created_at
      }.as_json)
    end
  end

end



