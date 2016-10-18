# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless Braintree Subscriptions' do
  include Requests::RequestHelpers
  include AuthToken

  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_braintree_customer, member: member) }
  let!(:payment_method) do
    create(:payment_braintree_payment_method,
           customer: customer,
           instrument_type: 'credit card',
           token: '2ewruo4i5o3',
           last_4: '2454',
           email: customer.email,
           card_type: 'Mastercard')
  end

  let(:month_ago) { 1.month.ago }

  let!(:subscription) do
    create(:payment_braintree_subscription,
           id: 1234,
           customer: customer,
           payment_method: payment_method,
           amount: 4,
           billing_day_of_month: 22,
           created_at: Time.now)
  end

  let!(:cancelled_subscription) do
    create(:payment_braintree_subscription,
           id: 12_345_678,
           customer: customer,
           payment_method: payment_method,
           amount: 4,
           billing_day_of_month: 22,
           created_at: month_ago,
           cancelled_at: month_ago)
  end

  let!(:transaction) do
    create(:payment_braintree_transaction,
           subscription: subscription,
           status: 'failure',
           amount: 100,
           created_at: Time.now)
  end

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
      expect(json_hash).to be_an Array
      subscription = json_hash.first.deep_symbolize_keys!
      expect(subscription).to include(id: 1234,
                                      created_at: /^\d{4}-\d{2}-\d{2}/,
                                      billing_day_of_month: 22,
                                      amount: '4.0',
                                      currency: 'GBP')

      expect(subscription[:payment_method]).to include(id: payment_method.id,
                                                       instrument_type: 'credit card',
                                                       token: '2ewruo4i5o3',
                                                       last_4: '2454',
                                                       expiration_date: '12/2050',
                                                       bin: nil,
                                                       email: customer.email,
                                                       card_type: 'Mastercard')

      expect(subscription[:transactions]).to include(id: transaction.id,
                                                     status: 'failure',
                                                     amount: '100.0',
                                                     created_at: /^\d{4}-\d{2}-\d{2}/)
    end

    it 'does not list subscriptions that have been cancelled' do
      get '/api/stateless/braintree/subscriptions', nil, auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.to_s).to_not include(cancelled_subscription.id.to_s)
    end
  end

  describe 'DELETE destroy' do
    let!(:cancel_this_subscription) do
      create(:payment_braintree_subscription, subscription_id: '4ts4r2', customer: customer)
    end

    let!(:no_such_subscription) do
      create(:payment_braintree_subscription, subscription_id: 'nosuchthing', customer: customer)
    end

    it 'deletes the subscription locally and on Braintree' do
      VCR.use_cassette('stateless api cancel subscription') do
        delete "/api/stateless/braintree/subscriptions/#{cancel_this_subscription.id}", nil, auth_headers
        expect(response.status).to eq(200)
        expect do
          ::Payment::Braintree::Subscription.find(cancel_this_subscription.id)
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    it 'returns success and deletes the subscription locally even if does not exist on Braintree' do
      VCR.use_cassette('stateless api cancel subscription failure') do
        delete "/api/stateless/braintree/subscriptions/#{no_such_subscription.id}", nil, auth_headers
        expect(response.status).to eq(200)
        expect do
          ::Payment::Braintree::Subscription.find(no_such_subscription.id)
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    it 'pushes a cancelled subscription event to the AK queue' do
      VCR.use_cassette('stateless api cancel subscription') do
        expect(ChampaignQueue).to receive(:push).with(type: 'cancel_subscription',
                                                      params: {
                                                        recurring_id: '4ts4r2',
                                                        canceled_by: 'user'
                                                      })

        delete "/api/stateless/braintree/subscriptions/#{cancel_this_subscription.id}", nil, auth_headers
      end
    end
  end
end
