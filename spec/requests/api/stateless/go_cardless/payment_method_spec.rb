# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless GoCardless PaymentMethods' do
  include Requests::RequestHelpers
  include AuthToken
  let!(:member) { create(:member, email: 'test@example.com') }
  let!(:customer) { create(:payment_go_cardless_customer, member: member) }

  before :each do
    member.create_authentication(password: 'password')
  end

  def auth_headers
    token = encode_jwt(member.token_payload)
    { authorization: "Bearer #{token}" }
  end

  describe 'GET index' do
    let!(:payment_method) do
      create(:payment_go_cardless_payment_method,
             customer: customer,
             id: 1432,
             go_cardless_id: 9898,
             scheme: 'bacs',
             next_possible_charge_date: Date.tomorrow,
             created_at: Time.now)
    end
    let!(:cancelled_method) do
      create(:payment_go_cardless_payment_method,
             customer: customer,
             go_cardless_id: 'asdfgf',
             cancelled_at: 1.month.ago)
    end

    it 'returns list of active payment methods for member' do
      get '/api/stateless/go_cardless/payment_methods', headers: auth_headers
      expect(response.status).to eq(200)
      expect(json_hash.first.deep_symbolize_keys!).to include(id: 1432,
                                                              go_cardless_id: '9898',
                                                              scheme: 'bacs',
                                                              next_possible_charge_date: /^\d{4}-\d{2}-\d{2}/,
                                                              created_at: /^\d{4}-\d{2}-\d{2}/)
    end

    it 'does not return payment methods that have been cancelled' do
      get '/api/stateless/go_cardless/payment_methods', headers: auth_headers
      expect(json_hash.to_s).to_not include(cancelled_method.go_cardless_id)
    end
  end

  describe 'DELETE destroy' do
    let!(:delete_me) do
      create(:payment_go_cardless_payment_method,
             customer: customer,
             id: 123,
             go_cardless_id: 'MD0000T982CR19',
             scheme: 'bacs',
             next_possible_charge_date: Date.tomorrow,
             created_at: Time.now)
    end

    let!(:i_dont_exist) do
      create(:payment_go_cardless_payment_method,
             customer: customer,
             id: 3490,
             go_cardless_id: 'nosuchthingongocardless',
             scheme: 'bacs',
             next_possible_charge_date: Date.tomorrow,
             created_at: Time.now)
    end

    let(:last_month) { 1.month.ago }

    let!(:subscription_a) do
      create(:payment_go_cardless_subscription,
             customer: customer,
             created_at: last_month,
             cancelled_at: nil,
             payment_method: delete_me)
    end

    let!(:subscription_b) do
      create(:payment_go_cardless_subscription,
             customer: customer,
             created_at: last_month,
             cancelled_at: last_month,
             payment_method: delete_me)
    end

    let!(:subscription_c) do
      create(:payment_go_cardless_subscription,
             customer: customer,
             created_at: last_month,
             cancelled_at: nil,
             payment_method: create(:payment_go_cardless_payment_method))
    end

    it 'cancels the mandate on GoCardless and sets the cancelled_at field in the local record' do
      Timecop.freeze do
        VCR.use_cassette('stateless api cancel go_cardless mandate') do
          delete "/api/stateless/go_cardless/payment_methods/#{delete_me.id}", headers: auth_headers
          expect(response.success?).to eq true
          expect(Payment::GoCardless::PaymentMethod.find(delete_me.id).cancelled_at)
            .to be_within(1.second).of Time.now
        end
      end
    end

    it 'marks active subcriptions with that method cancelled, but does not update cancelled subscriptions' do
      Timecop.freeze do
        VCR.use_cassette('stateless api cancel go_cardless mandate') do
          delete "/api/stateless/go_cardless/payment_methods/#{delete_me.id}", headers: auth_headers
          expect(subscription_a.reload.cancelled_at).to be_within(0.1.second).of(Time.now)
          expect(subscription_b.reload.cancelled_at).to be_within(0.1.second).of(last_month)
          expect(subscription_c.reload.cancelled_at).to eq(nil)
        end
      end
    end

    it 'returns errors and does not update the local record if GoCardless returns an error' do
      VCR.use_cassette('stateless api cancel go_cardless payment method failure') do
        expect(Rails.logger).to receive(:error).with('GoCardlessPro::InvalidApiUsageError occurred when cancelling'\
        ' mandate nosuchthingongocardless: Resource not found')
        delete "/api/stateless/go_cardless/payment_methods/#{i_dont_exist.id}", headers: auth_headers
        expect(response.success?).to eq false
        expect(json_hash['errors']).to eq([{ 'reason' => 'resource_not_found', 'message' => 'Resource not found' }])
        expect(Payment::GoCardless::PaymentMethod.find(i_dont_exist.id).cancelled_at).to be nil
      end
    end
  end
end
