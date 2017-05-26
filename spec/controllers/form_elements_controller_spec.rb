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

      post :create, params: { form_id: '1', form_element: params }
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

      post :sort, params: { form_id: '1', form_element_ids: '' }
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
      allow(FormElement).to receive(:includes) { FormElement }
      allow(FormElement).to receive(:find) { element }
      allow(element).to receive(:destroy)
      allow(element).to receive(:can_destroy?) { should_destroy }

      delete :destroy, params: { form_id: '1', id: '2', format: :json }
    end

    describe 'successfully' do
      let(:should_destroy) { true }

      it 'authenticates session' do
        expect(request.env['warden']).to have_received(:authenticate!)
      end

      it 'finds form element' do
        expect(FormElement).to have_received(:find).with('2')
      end

      it 'destroys element' do
        expect(element).to have_received(:destroy)
      end

      it 'checks that the element can be destroyed' do
        expect(element).to have_received(:can_destroy?)
      end

      it 'responds with 200' do
        expect(response.status).to eq 200
      end
    end

    describe 'unsuccessfully' do
      let(:element) { instance_double('FormElement', valid?: true, errors: { base: ['cannot be deleted'] }) }
      let(:should_destroy) { false }

      before :each do
        allow(element).to receive(:errors) { { base: ['cannot be deleted'] } }
      end

      let(:should_destroy) { false }

      it 'does not destroy element' do
        expect(element).to_not have_received(:destroy)
      end

      it 'responds with 422' do
        expect(response.status).to eq 422
      end

      it 'includes errors' do
        expect(response.body).to eq '{"errors":{"base":["cannot be deleted"]},"name":"form_element"}'
      end
    end
  end
end
