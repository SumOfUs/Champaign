# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless Braintree PaymentMethods' do
  include Requests::RequestHelpers
  include AuthToken
  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_braintree_customer, member: member) }
  let!(:method_a) { create(:payment_braintree_payment_method, :stored, customer: customer) }
  let!(:method_b) { create(:payment_braintree_payment_method, customer: customer) }
  let!(:subscription_a) { create(:payment_braintree_subscription, payment_method_id: method_a.id, cancelled_at: nil) }
  let!(:subscription_b) { create(:payment_braintree_subscription, payment_method_id: method_a.id, cancelled_at: nil) }
  let!(:subscription_c) { create(:payment_braintree_subscription, payment_method_id: method_b.id, cancelled_at: nil) }

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns stored payment methods for member' do
      get '/api/stateless/braintree/payment_methods', nil, auth_headers

      expect(json_hash.length).to eq(1)
    end

    it 'returns payment methods for member' do
      get '/api/stateless/braintree/payment_methods', nil, auth_headers

      expect(response.status).to eq(200)
      expect(json_hash.first.keys).to include('token', 'last_4', 'bin', 'email', 'expiration_date')
    end
  end

  describe 'DELETE destroy' do
    let(:success_object) { double(success?: true) }
    before do
      allow(::Braintree::PaymentMethod).to receive(:delete) { success_object }
      delete "/api/stateless/braintree/payment_methods/#{method_a.id}", nil, auth_headers
    end

    it 'destroys record locally' do
      expect(response.status).to eq(200)

      expect(
        Payment::Braintree::PaymentMethod.exists?(id: method_a.id)
      ).to be false
    end

    it 'destroys record from Braintree' do
      expect(::Braintree::PaymentMethod).to have_received(:delete).with(method_a.token)
    end

    it 'marks all local subcriptions associated with that payment method cancelled' do
      Timecop.freeze do
        expect(subscription_a.reload.cancelled_at).to be_within(0.1.second).of(Time.now)
        expect(subscription_b.reload.cancelled_at).to be_within(0.1.second).of(Time.now)
        expect(subscription_c.reload.cancelled_at).to eq(nil)
      end
    end
  end
end
