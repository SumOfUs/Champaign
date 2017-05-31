# frozen_string_literal: true

require 'rails_helper'

describe LinksController do
  let(:link) { instance_double('Link', save: true) }

  include_examples 'session authentication'

  describe 'POST #create' do
    let(:page) { instance_double('Page') }
    let(:params) { { url: 'http://google.com', title: 'Google.com' } }

    before do
      allow(Page).to receive(:find) { page }
      allow(Link).to receive(:new) { link }

      post :create, params: { page_id: '1', link: params }
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'does not bother to find page' do
      expect(Page).not_to have_received(:find)
    end

    it 'creates link' do
      ActionController::Parameters.permit_all_parameters = true

      expect(Link).to have_received(:new)
        .with(ActionController::Parameters.new(params))
    end

    it 'saves link' do
      expect(link).to have_received(:save)
    end

    context 'successfully created' do
      it 'renders link partial' do
        expect(response).to render_template('pages/_link')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(Link).to receive(:find) { link }
      allow(link).to receive(:destroy)

      delete :destroy, params: { page_id: '1', id: '2', format: :json }
    end

    it 'finds link' do
      expect(Link).to have_received(:find).with('2')
    end

    it 'destroys link' do
      expect(link).to have_received(:destroy)
    end
  end
end
