# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless PaymentMethods' do
  include Requests::JsonHelpers
  include AuthToken
  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_braintree_customer, member: member) }
  let!(:method_a) { create(:braintree_payment_method, customer: customer) }
  let!(:method_b) { create(:braintree_payment_method, customer: customer) }

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  it 'returns payment methods for member' do
    get '/api/stateless/braintree/payment_methods', nil, auth_headers
    expect(response.status).to eq(200)

    expect(json_hash.first.keys).to include('token', 'last_4', 'bin', 'email', 'expiration_date')
  end
end

