require 'rails_helper'

describe Api::PagesController do
  let(:page) { instance_double('Page', id: 1, to_param: '1') }
  let(:page_updater) { double(update: true, refresh?: true) }

  before do
    allow(Page).to receive(:find){ page }
    allow(PageUpdater).to receive(:new) { page_updater }
  end

  describe 'PUT update' do
    before do
      put :update, id: 1
    end

    it 'finds page' do
      expect(Page).to have_received(:find).with('1')
    end

    context 'PageUpdater' do
      it 'is instantiated' do
        expect(PageUpdater).to have_received(:new).with(page, "http://test.host/pages/1")
      end

      it 'calls update with params' do
        expect(page_updater).to have_received(:update).with({})
      end
    end
  end
end
