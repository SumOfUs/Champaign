require 'rails_helper'

describe Share::FacebooksController do
  let(:page) { instance_double('CampaignPage', title: 'Foo', content: 'Bar', id: '1', to_param: '1' ) }
  let(:share){ instance_double('Share::Facebook') }

  before do
    allow(CampaignPage).to receive(:find).with('1'){ page }
  end

  describe 'GET#index' do
    before do
      allow(Share::Facebook).to receive(:where){ [share] }

      get :index, campaign_page_id: '1'
    end

    it 'finds campaign page' do
      expect(CampaignPage).to have_received(:find).with('1')
    end

    it 'gets shares' do
      expect(Share::Facebook).to have_received(:where).
        with(campaign_page_id: '1')
    end

    it 'assigns shares' do
      expect( assigns(:variations) ).to eq([share])
    end

    it 'renders share/inded' do
      expect( response ).to render_template('share/index')
    end
  end

  describe 'GET#new' do
    before do
      allow(Share::Facebook).to receive(:new){ share }

      get :new, campaign_page_id: '1'
    end

    it 'finds campaign page' do
      expect(CampaignPage).to have_received(:find).with('1')
    end

    it 'instantiates instance of Share::Facebook with default values' do
      expect(Share::Facebook).to have_received(:new).with(title: 'Foo', description: 'Bar')
    end

    it 'assigns facebook' do
      expect( assigns(:facebook) ).to eq(share)
    end

    it 'renders share/new' do
      expect( response ).to render_template('share/new')
    end
  end

  describe 'GET#edit' do
    before do
      allow(Share::Facebook).to receive(:find){ share }
      get :edit, campaign_page_id: '1', id: '2'
    end

    it 'finds campaign page' do
      expect(CampaignPage).to have_received(:find).with('1')
    end

    it 'assigns share' do
      expect( assigns(:facebook) ).to eq(share)
    end

    it 'renders share/edit' do
      expect( response ).to render_template('share/edit')
    end
  end

  describe 'PUT#update' do
    before do
      allow(ShareProgressVariantBuilder).to receive(:update)

      put :update, campaign_page_id: 1, id: 2, share_facebook: {title: 'Foo'}
    end

    it 'finds campaign page' do
      expect(CampaignPage).to have_received(:find).with('1')
    end

    it 'updates' do
      expect(ShareProgressVariantBuilder).to have_received(:update).
        with({title: 'Foo'}, {
        variant_type: :facebook,
        campaign_page: page,
        url: "http://test.host/campaign_pages/1",
        id: '2'
      })
    end

    it 'redirects to share index path' do
      expect( response ).to redirect_to('/campaign_pages/1/share/facebooks')
    end
  end

  describe 'POST#create' do
    before do
      allow(ShareProgressVariantBuilder).to receive(:create)

      post :create, campaign_page_id: 1, share_facebook: {title: 'Foo'}
    end

    it 'finds campaign page' do
      expect(CampaignPage).to have_received(:find).with('1')
    end

    it 'creates' do
      expect(ShareProgressVariantBuilder).to have_received(:create).
        with({title: 'Foo'}, {
        variant_type: :facebook,
        campaign_page: page,
        url: "http://test.host/campaign_pages/1"
      })
    end

    it 'redirects to share index path' do
      expect( response ).to redirect_to('/campaign_pages/1/share/facebooks')
    end
  end
end

