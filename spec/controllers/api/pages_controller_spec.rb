# frozen_string_literal: true
require 'rails_helper'

describe Api::PagesController do
  let(:page) { instance_double('Page', id: 1, to_param: '1', to_json: '') }
  let(:page_updater) { double(update: true, refresh?: true) }

  before do
    allow(Page).to receive(:find) { page }
  end

  describe 'GET index' do
    before do
      allow(PageService).to receive(:list)
      get :index, params: { language: 'en', format: :json }
    end

    it 'gets list of pages' do
      expect(PageService).to have_received(:list).with(hash_including(language: 'en'))
    end

    it 'responds with json' do
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET featured' do
    before do
      allow(PageService).to receive(:list_featured)
      get :featured, params: { language: 'en', format: :json }
    end

    it 'gets list of pages' do
      expect(PageService).to have_received(:list_featured).with(hash_including(language: 'en'))
    end

    it 'responds with json' do
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'PUT update' do
    it 'is redirected if the user is not logged in' do
      allow(controller).to receive(:user_signed_in?).and_return(false)
      expect(put(:update, params: { id: 1 })).to redirect_to(new_user_session_url)
    end

    context 'logged in' do
      before do
        allow(PageUpdater).to receive(:new).and_return(page_updater)
        allow(request.env['warden']).to receive(:authenticate!) { double }
        put :update, params: { id: 1 }
      end

      it 'finds page' do
        expect(Page).to have_received(:find).with('1')
      end

      it 'returns success' do
        expect(response.code).to eq '200'
      end

      describe 'PageUpdater' do
        it 'is instantiated' do
          expect(PageUpdater).to have_received(:new).with(page, 'http://test.host/pages/1')
        end

        it 'calls update with params' do
          expect(page_updater).to have_received(:update).with({})
        end
      end
    end
  end

  describe 'GET show' do
    context 'for existing page' do
      before { get :show, params: { id: '2', format: 'json' } }

      it 'finds page' do
        expect(Page).to have_received(:find).with('2')
      end

      it 'renders json' do
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'record not found' do
      before do
        allow(Page).to receive(:find) { raise ActiveRecord::RecordNotFound }
        get :show, params: { id: '2' }
      end

      it 'renders json' do
        expect(response.body).to match(/No record was found/)
      end
    end
  end

  describe 'GET actions' do
    subject { get :actions, params: { id: '2' } }

    it 'returns a 403 if the page publish_actions is secure' do
      allow(page).to receive(:secure?).and_return(true)
      subject
      expect(response.code).to eq '403'
    end

    it 'calls ActionReader if page publish_actions is default_hidden' do
      allow(page).to receive(:secure?).and_return(false)
      allow(page).to receive(:default_hidden?).and_return(true)
      ar = instance_double(ActionReader, run: [])
      allow(ActionReader).to receive(:new).and_return(ar)
      expect(ActionReader).to receive(:new)
      expect(ar).to receive(:run)
      subject
    end
  end
end
