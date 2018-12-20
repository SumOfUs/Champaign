# frozen_string_literal: true

require 'rails_helper'

describe 'Donations endpoint' do
  describe 'GET#totals' do
    it 'returns a json api compatible response' do
      get '/api/donations/total', params: {
        start: Date.today.beginning_of_month.to_s,
        end: Date.today.to_s
      }
      expect(json_hash).to include('meta', 'data')
      expect(json_hash['data']).to include('total_donations')
    end

    it 'returns total_donations for all supported currencies' do
      get '/api/donations/total', params: {
        start: Date.today.beginning_of_month.to_s,
        end: Date.today.to_s
      }
      expect(json_hash).to include('meta', 'data')
      expect(json_hash['data']['total_donations']).to include(*TransactionService::CURRENCIES.map(&:to_s))
    end

    it 'returns a `meta` field with the query params' do
      params = {
        start: Date.today.beginning_of_month.to_s,
        end: Date.today.to_s
      }

      get '/api/donations/total', params: params

      expect(json_hash['meta']['start']).to eq(params[:start])
      expect(json_hash['meta']['end']).to eq(params[:end])
    end

    it 'defaults to the beginning of the current month for `start`' do
      get '/api/donations/total'
      expect(json_hash['meta']['start']).to eq(Date.today.beginning_of_month.to_s)
    end

    it 'defaults to the end of the current month for `end`' do
      get '/api/donations/total'
      expect(json_hash['meta']['end']).to eq(Date.today.end_of_month.to_s)
    end

    it 'returns a 404 Bad Request when start is not a date' do
      get '/api/donations/total', params: { start: 'not a date' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 404 Bad Request when end is not a date' do
      get '/api/donations/total', params: { end: 'not a date' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 404 Bad Request when start is later than end' do
      get '/api/donations/total', params: { start: '2018-12-12', end: '2018-10-10' }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
