# frozen_string_literal: true
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

      it 'parses JSON choices while leaving non-JSON choices' do
        choices = ['{"label": "Cluck", "value": "chicken"}', "Meower"]
        element = FormElementBuilder.create(form, params.merge(choices: choices))
        expect(form.form_elements.first.choices).to eq [{'label' => 'Cluck', 'value' => 'chicken'}, 'Meower']
      end
    end
  end
end
