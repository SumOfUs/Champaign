require 'rails_helper'

describe CampaignPagesController do
  let(:user) { instance_double('User') }
  let(:campaign_page) { instance_double('CampaignPage', active?: true, featured?: true) }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
  end

  describe 'GET #index' do
    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    let(:page) { instance_double(CampaignPage, valid?: true) }

    before do
      allow(CampaignPageBuilder).to receive(:create_with_plugins) { page }
      post :create, { campaign_page: { title: "Foo Bar" }}
    end

    it 'creates page' do
      expected_params = { title: "Foo Bar" }

      expect(CampaignPageBuilder).to have_received(:create_with_plugins).
        with(expected_params)
    end

    context "successfully created" do
      it 'redirects to edit_campaign_page' do
        expect(response).to redirect_to(edit_campaign_page_path(page))
      end
    end

    context "successfully created" do
      let(:page) { instance_double(CampaignPage, valid?: false) }

      it 'redirects to edit_campaign_page' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT #update' do
    let(:page) { instance_double(CampaignPage) }

    before do
      allow(CampaignPage).to receive(:find){ page }
      allow(page).to receive(:update)
      put :update, id: '1', campaign_page: { title: 'bar' }
    end

    it 'finds the campaign page' do
      expect(CampaignPage).to have_received(:find).with('1')
    end

    it 'udpates the campaign page' do
      expect(page).to have_received(:update).with(title: 'bar')
    end
  end

  describe 'GET #show' do
    it 'finds campaign page'
    it 'collects markup data'
    it 'renders show template'
  end
end


