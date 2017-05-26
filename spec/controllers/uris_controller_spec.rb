# frozen_string_literal: true
require 'rails_helper'

describe UrisController do
  let(:uri) { instance_double('Uri', save: true) }

  before do
    allow(Uri).to receive(:find) { uri }
  end

  include_examples 'session authentication'

  describe 'GET #index' do
    let(:uris) { [build(:uri), build(:uri)] }

    before :each do
      allow(Uri).to receive(:all).and_return(uris)
    end

    it 'assigns all uris as @uris' do
      get :index
      expect(assigns(:uris)).to eq(uris)
    end
  end

  describe 'POST #create' do
    let(:params) { { domain: 'google.com', path: '/giddyup', page_id: '1' } }

    before do
      allow(Uri).to receive(:new) { uri }

      post :create, params: { uri: params }
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'creates uri' do
      expect(Uri).to have_received(:new).with(params.stringify_keys)
    end

    it 'saves uri' do
      expect(uri).to have_received(:save)
    end

    context 'successfully created' do
      it 'renders uri partial' do
        expect(response).to render_template('_uri')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(uri).to receive(:destroy)

      delete :destroy, params: { id: '2', format: :json }
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds uri' do
      expect(Uri).to have_received(:find).with('2')
    end

    it 'destroys uri' do
      expect(uri).to have_received(:destroy)
    end
  end
end
