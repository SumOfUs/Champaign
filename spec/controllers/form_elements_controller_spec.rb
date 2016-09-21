# frozen_string_literal: true
require 'rails_helper'

describe FormElementsController do
  let(:element) { instance_double('FormElement', valid?: true) }
  let(:form) { instance_double('Form') }

  include_examples 'session authentication'

  describe 'POST #create' do
    let(:params) { { label: 'Label', data_type: 'text', required: true } }

    before do
      allow(Form).to receive(:find) { form }
      allow(FormElementBuilder).to receive(:create) { element }

      post :create, form_id: '1', form_element: params
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds form' do
      expect(Form).to have_received(:find).with('1')
    end

    it 'creates form element' do
      expect(FormElementBuilder).to have_received(:create).with(form, params)
    end

    context 'successfully created' do
      it 'renders element partial' do
        expect(response).to render_template('form_elements/_element')
      end
    end
  end

  describe 'POST #sort' do
    before do
      allow(Form).to receive(:find) { form }
      allow(form).to receive(:touch)
      allow(form).to receive(:form_elements) { [] }

      post :sort, form_id: '1', form_element_ids: ''
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds form' do
      expect(Form).to have_received(:find).with('1')
    end

    it 'touches form' do
      expect(form).to have_received(:touch)
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(FormElement).to receive(:find) { element }
      allow(element).to receive(:destroy)

      delete :destroy, form_id: '1', id: '2', format: :json
    end

    it 'authenticates session' do
      expect(request.env['warden']).to have_received(:authenticate!)
    end

    it 'finds form element' do
      expect(FormElement).to have_received(:find).with('2')
    end

    it 'destroys element' do
      expect(element).to have_received(:destroy)
    end
  end
end
