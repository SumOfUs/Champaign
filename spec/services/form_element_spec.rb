# frozen_string_literal: true

require 'rails_helper'

describe FormElementBuilder do
  describe '.create' do
    let(:form) { create(:form) }
    let(:params) { attributes_for(:form_element) }

    it 'creates a form element associated with form' do
      element = FormElementBuilder.create(form, params)

      expect(form.form_elements.first).to eq(element)
    end
  end
end
