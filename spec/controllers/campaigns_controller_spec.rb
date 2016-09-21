# frozen_string_literal: true
require 'rails_helper'

describe CampaignsController do
  let(:campaign) { instance_double('Campaign') }

  before do
    allow(Campaign).to receive(:find) { campaign }
  end

  include_examples 'session authentication',
                   { get:  [:index],
                     get:  [:new],
                     get:  [:edit, id: 1],
                     get:  [:show, id: 1]}

  describe 'GET index' do
    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET new' do
    before do
      allow(Campaign).to receive(:new) { campaign }
      get :new
    end

    it 'instantiates instance of Campaign' do
      expect(Campaign).to have_received(:new)
    end

    it 'assigns campaign' do
      expect(assigns(:campaign)).to eq(campaign)
    end

    it 'renders new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'GET edit' do
    before do
      get :edit, id: 1
    end

    it 'instantiates instance of Campaign' do
      expect(Campaign).to have_received(:find).with('1')
    end

    it 'assigns campaign' do
      expect(assigns(:campaign)).to eq(campaign)
    end

    it 'renders edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET show' do
    it 'finds campaign' do
      expect(Campaign).to receive(:find).with('1')
      get :show, id: 1
    end

    it 'assigns campaign' do
      get :show, id: '1'
      expect(assigns(:campaign)).to eq(campaign)
    end
  end

  describe 'POST create' do
    let(:fake_params) { { 'name' => 'Foo' } }
    let(:campaign) { double(persisted?: true) }

    before do
      allow(CampaignCreator).to receive(:run) { campaign }
      post :create, campaign: fake_params
    end

    it 'authenticates session' do
      expect(request.env['warden']).to receive(:authenticate!)
      post :create, campaign: fake_params
    end

    it 'calls CampaignCreator.run' do
      expect(CampaignCreator).to have_received(:run).with(fake_params)
    end

    it 'responds with notice' do
      expect(flash[:notice]).to eq('Campaign has been created.')
    end

    it 'assigns campaign' do
      expect(assigns(:campaign)).to eq(campaign)
    end

    it 'redirects to campaign' do
      expect(response).to redirect_to(campaigns_path)
    end
  end
end
