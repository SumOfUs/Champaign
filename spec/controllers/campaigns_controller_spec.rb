require 'rails_helper'

describe CampaignsController do
  let(:user) { double(:user) }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
  end

  describe 'GET index' do
    let(:campaign) { double(:campaign) }

    before do
      allow(Campaign).to receive(:active).and_return([campaign])
    end

    it 'gets active campaigns' do
      expect(Campaign).to receive(:active)
      get :index
    end

    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end

    it 'assigns @campaigns' do
      get :index
      expect(assigns(:campaigns)).to eq([campaign])
    end
  end
end

