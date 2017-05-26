# frozen_string_literal: true
require 'rails_helper'

describe ClonePagesController do
  let(:page) { double }
  let(:user) { double }

  before do
    allow(Page).to receive(:find) { page }
    allow(request.env['warden']).to receive(:authenticate!) { user }
  end

  describe 'GET #new' do
    before do
      get :new, params: { id: '1' }
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds page' do
      expect(Page).to have_received(:find).with('1')
    end

    it 'assigns page' do
      expect(assigns(:page)).to eq(page)
    end

    it 'renders new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:cloned_page) { build('page', slug: 'foo-bar') }

    before do
      allow(PageCloner).to receive(:clone) { cloned_page }
      allow(QueueManager).to receive(:push)

      post :create, params: { id: '1', page: { title: 'foo', language_id: 3 }, override_forms: '1' }
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds page' do
      expect(Page).to have_received(:find).with('1')
    end

    it 'clones page' do
      expect(PageCloner).to have_received(:clone).with(page, 'foo', '3', true)
    end

    it 'posts page to queue' do
      expect(QueueManager).to have_received(:push).with(cloned_page, job_type: :create)
    end

    it 'redirects to cloned page' do
      expect(response).to redirect_to('/pages/foo-bar/edit')
    end
  end
end
