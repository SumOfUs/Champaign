# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
  context 'with valid auth headers' do
    let(:valid_headers) do
      {
        'X-CHAMPAIGN-SIGNATURE' => '2d39dea4bc00ceff1ec1fdf160540400f673e97474b1d197d240b084bd186d34',
        'X-CHAMPAIGN-NONCE' => 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
      }
    end

    let!(:donation) do
      create(:payment_braintree_subscription,
             subscription_id: 'BraintreeWoohoo',
             cancelled_at: nil)
    end

    it 'sends back 200 and persists the nonce' do
      expect(Authentication::Nonce.exists?(nonce: 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621')).to be false
      delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo', headers: valid_headers
      expect(response.status).to eq 200
      expect(Authentication::Nonce.exists?(nonce: 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621')).to be true
    end
  end

  context 'with invalid auth headers' do
    let(:bogus_header) do
      {
        'X-CHAMPAIGN-SIGNATURE' => 'olololololo',
        'X-CHAMPAIGN-NONCE' => 'wololo'
      }
    end

    it 'logs an access violation and sends back status 401' do
      error_string = 'Access violation for member services API.'
      expect(Rails.logger).to receive(:error).with(error_string)
      delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo', headers: bogus_header
      expect(response.status).to eq 401
      expect(response.body).to include('Invalid authentication header')
    end
  end

  context 'with missing auth headers' do
    it 'sends back 401 complains about missing auth headers' do
      delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo'
      expect(response.status).to eq 401
      expect(response.body).to include('Missing authentication header or nonce.')
    end
  end

  context 'with a used nonce' do
    let(:valid_headers) do
      {
        'X-CHAMPAIGN-SIGNATURE' => '2d39dea4bc00ceff1ec1fdf160540400f673e97474b1d197d240b084bd186d34',
        'X-CHAMPAIGN-NONCE' => 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
      }
    end

    it 'sends back 401 and complains about a nonce that has already been used' do
      Authentication::Nonce.create!(nonce: 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621')
      delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo', headers: valid_headers
      expect(response.status).to eq 401
      expect(response.body).to include('The nonce has already been used.')
    end
  end
end
