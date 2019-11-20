# frozen_string_literal: true

require 'rails_helper'

describe 'URI masking' do
  let(:user) { instance_double('User', id: '1') }
  let(:page) { create :page }
  VCR.use_cassette('money_from_oxr') do
    describe 'when no record matches' do
      it 'routes to homepage  if requested by an unauthenticated user' do
        expect(get('/random')).to redirect_to(Settings.home_page_url)
      end

      it 'routes to /pages if requested by an authenticated user' do
        login_as(create(:user), scope: :user)
        expect(get('/random')).to redirect_to(pages_path)
      end
    end

    it 'renders matching URI record when path is not root' do
      create :uri, domain: 'www.example.com', path: 'random', page: page
      allow(LiquidRenderer).to receive(:new).and_call_original
      get '/random'
      expect(response.status).to eq 200
      expect(response).to render_template('pages/show')
      expect(LiquidRenderer).to have_received(:new)
    end

    it 'renders matching URI record when path is root' do
      create :uri, domain: 'www.example.com', path: '/', page: page
      allow(LiquidRenderer).to receive(:new).and_call_original
      get '/'
      expect(response.status).to eq 200
      expect(response).to render_template('pages/show')
      expect(LiquidRenderer).to have_received(:new)
    end
  end
end
