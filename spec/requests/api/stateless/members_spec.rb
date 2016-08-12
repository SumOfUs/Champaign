require 'rails_helper'

describe 'API::Stateless Members' do
  include Requests::JsonHelpers
  include AuthToken
  let!(:member) { create(:member, first_name: 'Harriet', last_name: 'Tubman', email: 'test@example.com') }
  let!(:customer) { create(:payment_braintree_customer, member: member) }
  let!(:method_a) { create(:braintree_payment_method, customer: customer) }
  let!(:method_b) { create(:braintree_payment_method, customer: customer) }
  let!(:subscription_a) { create(:payment_braintree_subscription, customer: customer) }
  let!(:transaction_a) { create(:payment_braintree_transaction, subscription: subscription_a, customer: customer)}

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET show' do
    it 'returns member information for the member' do
      get "/api/stateless/members/#{member.id}", nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.keys).to include('id', 'first_name', 'last_name', 'email')
      expect(json_hash).to match({
                                   id: member.id,
                                   first_name: member.first_name,
                                   last_name: member.last_name,
                                   email: member.email
                                 }.as_json)
    end
  end

end


