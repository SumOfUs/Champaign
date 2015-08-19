require 'rails_helper'

describe PluginsController do
  let(:plugin) { instance_double('Plugins::Action') }
  let(:page)   { instance_double('CampaignPage', id: 5) }

  before do
    allow(Plugins).to receive(:find_for){ plugin }
    allow(CampaignPage).to receive(:find){ page }
    get :show, id: '1', campaign_page_id: '2'
  end

  describe 'GET #show' do
    it 'renders show' do
      expect(response).to render_template('show')
    end

    it 'finds campaign page' do
      expect(CampaignPage).to have_received(:find).with('2')
    end

    it 'finds plugin' do
      expect(Plugins).to have_received(:find_for).with(5, '1')
    end
  end
end
