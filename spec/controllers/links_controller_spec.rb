require 'rails_helper'

describe LinksController do
  let(:link) { instance_double('Link', save: true) }

  describe 'POST #create' do
    let(:campaign_page) { instance_double('CampaignPage') }
    let(:params) { { url: "http://google.com", title: 'Google.com' } }

    before do
      allow(CampaignPage).to receive(:find){ campaign_page }
      allow(Link).to receive(:new) { link }

      post :create, campaign_page_id: '1', link: params
    end

    it 'does not bother to find campaign_page' do
      expect(CampaignPage).not_to have_received(:find)
    end

    it 'creates link' do
      expect(Link).to have_received(:new).with(params)
    end

    it 'saves link' do
      expect(link).to have_received(:save)
    end

    context "successfully created" do
      it 'renders link partial' do
        expect(response).to render_template('campaign_pages/_link')
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      allow(Link).to receive(:find){ link }
      allow(link).to receive(:destroy)

      delete :destroy, campaign_page_id: '1', id: '2', format: :json
    end

    it 'finds link' do
      expect(Link).to have_received(:find).with('2')
    end

    it 'destroys link' do
      expect(link).to have_received(:destroy)
    end
  end
end
