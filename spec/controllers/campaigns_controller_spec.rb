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
      allow(ActiveQuery).to receive(:new).and_return([campaign])
    end

    it 'gets active campaigns' do
      expect(ActiveQuery).to receive(:new).with(Campaign)
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

