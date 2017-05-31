# frozen_string_literal: true

require 'rails_helper'

describe Api::AnalyticsController do
  describe 'GET #show' do
    let(:page) { double }

    before do
      allow(Analytics::Page).to receive(:new) { page }
      get :show, params: { page_id: '1', format: 'json' }
    end

    it 'assigns page' do
      expect(assigns(:page)).to eq(page)
    end

    it 'creates analytics object' do
      expect(Analytics::Page).to have_received(:new).with('1')
    end

    it 'renders json template' do
      expect(response).to render_template :show
    end
  end
end
