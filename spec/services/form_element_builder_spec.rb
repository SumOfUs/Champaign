require 'rails_helper'

describe FormElementBuilder do
  subject { described_class }

  let(:form) { create(:form) }
  let(:params) { attributes_for(:form_element) }

  describe '.create' do
    context 'with valid params' do
      it 'creates an element for a passed form' do
        element = FormElementBuilder.create(form, params)
        expect(form.form_elements.first).to eq(element)
      end
    end

    context 'with invalid params' do
      let(:params) { attributes_for(:form_element).merge(name: nil) }

      it 'returns invalid element' do
        element = FormElementBuilder.create(form, params)
        expect(element).to_not be_valid
        expect(form.form_elements).to be_empty
      end
    end
  end
end

