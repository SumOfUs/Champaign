# frozen_string_literal: true

require 'rails_helper'

describe 'API::Stateless GoCardless Subscriptions', focus: true do
  include Requests::RequestHelpers
  include AuthToken

  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) do
    create(:payment_go_cardless_customer,
           member: member,
           go_cardless_id: '1337',
           email: 'test@example.com',
           country_code: 'US',
           language: 'en')
  end
  let!(:payment_method) do
    create(:payment_go_cardless_payment_method,
           id: 321,
           go_cardless_id: 1_234_566,
           customer: customer,
           scheme: 'sepa_core',
           created_at: Time.now,
           next_possible_charge_date: Date.tomorrow)
  end
  let!(:subscription) do
    create(:payment_go_cardless_subscription,
           customer: customer,
           payment_method: payment_method,
           id: 1234,
           go_cardless_id: '13243',
           amount: '5.0',
           currency: 'USD',
           name: nil,
           created_at: Date.today)
  end
  let(:last_month) { 1.month.ago }
  let!(:cancelled_subscription) do
    create(:payment_go_cardless_subscription,
           customer: customer,
           payment_method: payment_method,
           id: 12_345_678,
           go_cardless_id: '11323',
           amount: '5.0',
           currency: 'USD',
           name: nil,
           created_at: last_month,
           cancelled_at: last_month)
  end
  let!(:transaction) do
    VCR.use_cassette('money_from_oxr') do
      create :payment_go_cardless_transaction,
             subscription: subscription,
             customer: customer,
             go_cardless_id: 999,
             amount: 4,
             currency: 'GBP',
             charge_date: Date.tomorrow,
             payment_method: payment_method
    end
  end

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    it 'returns subscriptions with nested transactions and payment method' do
      get '/api/stateless/go_cardless/subscriptions', headers: auth_headers
      expect(response.status).to eq(200)
      expect(json_hash).to be_an Array
      subscription = json_hash.first.deep_symbolize_keys!
      expect(subscription).to include(id: 1234,
                                      go_cardless_id: '13243',
                                      amount: '5.0',
                                      currency: 'USD',
                                      name: nil,
                                      state: 'pending',
                                      created_at: /^\d{4}-\d{2}-\d{2}/)
      expect(subscription[:payment_method]).to include(id: 321,
                                                       go_cardless_id: '1234566',
                                                       scheme: 'sepa_core',
                                                       next_possible_charge_date: /^\d{4}-\d{2}-\d{2}/,
                                                       created_at: /^\d{4}-\d{2}-\d{2}/)
      expect(subscription[:transactions]).to include(id: transaction.id,
                                                     go_cardless_id: '999',
                                                     charge_date: /^\d{4}-\d{2}-\d{2}/,
                                                     state: 'created')
    end

    it 'does not show subscriptions that have been marked as cancelled' do
      get '/api/stateless/go_cardless/subscriptions', headers: auth_headers
      expect(json_hash.to_s).to_not include(cancelled_subscription.id.to_s)
    end
  end

  describe 'PUT update' do
    let(:valid_attributes) {
      { ak_order_id: '1873844' }
    }

    let(:valid_api_key) {
      { 'X-Api-Key' => '1234' }
    }

    let(:invalid_api_key) {
      { 'X-Api-Key' => '124' }
    }

    context 'existing record' do
      it 'should update ak_order_id' do
        go_cardless_id = subscription.go_cardless_id
        put "/api/stateless/go_cardless/subscriptions/#{go_cardless_id}", params: valid_attributes,
                                                                          headers: valid_api_key

        expect(response.code).to eql '200'
        expect(json_ostruct.success).to eq true
      end
    end

    context 'non existing record' do
      it 'should return 404' do
        put '/api/stateless/go_cardless/subscriptions/123', params: valid_attributes,
                                                            headers: valid_api_key
        expect(response.code).to eql '200'
        expect(json_ostruct.message).to match 'record not found'
      end
    end

    context 'invalid api token' do
      it 'should not process the request if the header has invalid api token' do
        go_cardless_id = subscription.go_cardless_id
        put "/api/stateless/go_cardless/subscriptions/#{go_cardless_id}", params: valid_attributes,
                                                                          headers: invalid_api_key
        expect(response.code).to eql '403'
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:delete_subscription) do
      create(:payment_go_cardless_subscription,
             customer: customer,
             payment_method: payment_method,
             id: 93_829,
             go_cardless_id: 'SB00003GHBQ3YF',
             amount: '5.0',
             currency: 'USD',
             name: nil,
             cancelled_at: nil,
             created_at: Date.today)
    end

    let!(:nonexistent_subscription) do
      create(:payment_go_cardless_subscription,
             customer: customer,
             payment_method: payment_method,
             go_cardless_id: 'idontexist')
    end

    it 'cancels the subscription on GoCardless and marks the local subscription as cancelled' do
      Timecop.freeze do
        VCR.use_cassette('stateless api cancel go_cardless subscription') do
          delete "/api/stateless/go_cardless/subscriptions/#{delete_subscription.id}", headers: auth_headers
          expect(response.successful?).to eq true
          expect(Payment::GoCardless::Subscription.find(delete_subscription.id).cancelled_at)
            .to be_within(1.second).of Time.now
        end
      end
    end

    it 'returns errors and does not update the local record if GoCardless returns an error' do
      VCR.use_cassette('stateless api cancel go_cardless subscription failure') do
        expect(Rails.logger).to receive(:error).with('GoCardlessPro::InvalidApiUsageError occurred when cancelling'\
        ' subscription idontexist: Resource not found')
        delete "/api/stateless/go_cardless/subscriptions/#{nonexistent_subscription.id}", headers: auth_headers
        expect(response.successful?).to eq false
        expect(json_hash['errors']).to eq([{ 'reason' => 'resource_not_found', 'message' => 'Resource not found' }])
        expect(Payment::GoCardless::Subscription.find(nonexistent_subscription.id).cancelled_at).to be nil
      end
    end

    it 'pushes a cancelled subscription event to the event queue' do
      VCR.use_cassette('stateless api cancel go_cardless subscription') do
        expect(ChampaignQueue).to receive(:push).with(
          { type: 'cancel_subscription',
            params: {
              recurring_id: 'SB00003GHBQ3YF',
              canceled_by: 'user'
            } },
          { group_id: "gocardless-subscription:#{delete_subscription.id}" }
        )

        delete "/api/stateless/go_cardless/subscriptions/#{delete_subscription.id}", headers: auth_headers
      end
    end
  end
end
