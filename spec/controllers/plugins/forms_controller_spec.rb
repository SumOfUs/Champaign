# frozen_string_literal: true
require 'rails_helper'

describe Plugins::FormsController do
  let(:user) { instance_double('User', id: 1) }
  let(:petition) { build :plugins_petition }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(Plugins).to receive(:find_for).and_return(petition)
  end

  describe 'GET show' do
    let(:params) { { params: { plugin_type: 'petition', plugin_id: '3' } } }

    before :each do
      get :show, params
    end

    it 'finds the plugin' do
      expect(Plugins).to have_received(:find_for).with(params[:plugin_type], params[:plugin_id])
    end

    it 'renders the form preview' do
      expect(response).to render_template(partial: 'plugins/shared/_preview')
    end
  end

  describe 'POST create' do
    let(:params) { { params: { master_id: '2', plugin_type: 'petition', plugin_id: '3' } } }
    let(:first_form) { instance_double('Form', id: 1, master: true) }
    let(:second_form) { instance_double('Form', id: 7, master: false) }

    before do
      allow(Form).to receive(:find).and_return(first_form)
      allow(FormDuplicator).to receive(:duplicate).and_return(second_form)
      allow(petition).to receive(:update_form)
      request.accept = 'application/json'
      post :create, params
    end

    it 'finds form by form_id' do
      expect(Form).to have_received(:find).with(params[:master_id])
    end

    it 'finds plugin by plugin type and id' do
      expect(Plugins).to have_received(:find_for).with(params[:plugin_type], params[:plugin_id])
    end

    it 'duplicates the form' do
      expect(FormDuplicator).to have_received(:duplicate).with(first_form)
    end

    it 'calls plugin.update_form with the duplicated form' do
      expect(petition).to have_received(:update_form).with(second_form)
    end

    it 'returns the form rendered as html in a json blob' do
      expect(response.status).to eq 200
      expect(response).to render_template(partial: 'forms/_edit')
      body = JSON.parse(response.body)
      expect(body.keys).to match_array %w(html form_id)
      expect(body['form_id']).to eq second_form.id
    end
  end

  describe 'strong params' do
    let(:params) { { params: { master_id: '2', plugin_type: 'petition', plugin_id: '3', form_id: 'disallowed' } } }

    it 'are used for POST create' do
      expect { post :create, params }.to raise_error(ActionController::UnpermittedParameters)
    end

    it 'are used for GET show' do
      expect { get :show, params }.to raise_error(ActionController::UnpermittedParameters)
    end
  end
end
