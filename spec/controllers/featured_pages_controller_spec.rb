# frozen_string_literal: true
require 'rails_helper'

describe FeaturedPagesController do
  let(:page) { double('Page') }

  include_examples 'session authentication',
                   [{ post:   [:create, params: { format: :js }] },
                    { delete: [:destroy, params: { id: '1', format: :js }] }]

  before do
    allow(Page).to receive(:find) { page }
    allow(page).to receive(:update)
  end

  describe 'POST #create' do
    before do
      post :create, params: { id: '1', format: :js }
    end

    it 'finds page' do
      expect(Page).to have_received(:find).with('1')
    end

    it 'sets page#featured to true' do
      expect(page).to have_received(:update).with(featured: true)
    end

    it 'renders show template' do
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy, params: { id: '1', format: :js }
    end

    it 'finds page' do
      expect(Page).to have_received(:find).with('1')
    end

    it 'sets page#featured to false' do
      expect(page).to have_received(:update).with(featured: false)
    end

    it 'renders show template' do
      expect(response).to render_template(:show)
    end
  end
end
