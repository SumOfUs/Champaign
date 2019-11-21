require 'rails_helper'

RSpec.describe Api::DonationsController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'GET #total' do
    it 'returns http success' do
      get :total
      expect(response).to have_http_status(:success)
    end

    it 'returns a JSON API compatible response' do
      get :total
      expect(response.body).to match('meta')
      expect(response.body).to match('data')
    end

    it 'retuns a 400 Bad Request when start is greater than end date' do
      get :total, params: { start: '2019-1-1', end: '2018-12-31' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 400 Bad Request when start is not a date' do
      get :total, params: { start: 'not a date' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns a 400 Bad Request when end is not a date' do
      get :total, params: { end: 'not a date' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns both total donations and EOY fundraising goals' do
      get :total, params: { start: '2019-11-29', end: '2019-12-31' }
      json_hash = JSON.parse(response.body).with_indifferent_access
      expect(json_hash[:data].keys).to match(%w[total_donations eoy_goals])
      expect(json_hash[:data][:eoy_goals].keys).to match(%w[USD GBP EUR CHF AUD NZD CAD])
      expect(json_hash[:data][:total_donations].keys).to match(%w[USD GBP EUR CHF AUD NZD CAD])
    end
  end
end
