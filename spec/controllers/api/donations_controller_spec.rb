require 'rails_helper'

RSpec.describe Api::DonationsController, type: :controller do
  describe 'GET #total' do
    it 'returns http success' do
      get :total
      expect(response).to have_http_status(:success)
    end
  end
end
