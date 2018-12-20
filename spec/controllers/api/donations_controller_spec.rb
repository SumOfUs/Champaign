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
  end
end
