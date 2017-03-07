# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless Location' do
  describe 'GET /api/stateless/location' do
    context 'Geocoder Success' do
      it 'responds with (at least) a country code and a currency' do
        get '/api/stateless/location'
        expect(response.status).to eq(200)
        expect(response.body).to include_json(
          location: {
            country_code: 'RD',
            currency: 'USD'
          }
        )
      end
    end

    context 'Geocoder Timeout' do
      before do
        allow(Geocoder).to receive(:search) { [] }
      end

      it 'responds with a 504 Gateway Timeout' do
        get '/api/stateless/location'
        expect(response.status).to eq(504)
      end

      after do
        allow(Geocoder).to receive(:search).and_call_original
      end
    end
  end
end
