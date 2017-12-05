# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
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
    it 'complains about missing auth headers' do
      delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo'
      expect(response.status).to eq 401
      expect(response.body).to include('Missing authentication header or nonce.')
    end
  end
end
