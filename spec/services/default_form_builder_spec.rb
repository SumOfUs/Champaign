# frozen_string_literal: true
require 'rails_helper'

describe DefaultFormBuilder do
  it 'creates a default master form' do
    expect do
      DefaultFormBuilder.find_or_create
    end.to change { Form.count }.from(0).to(1)
  end

  it 'creates fields' do
    expect(DefaultFormBuilder.find_or_create.form_elements.size).to eq(4)
  end

  describe 'i18n' do
    it 'translates the fields to German' do
      expect(DefaultFormBuilder.find_or_create(locale: 'de').form_elements.first.label).to eq 'E-MAIL'
    end

    it 'translates the fields to French' do
      expect(DefaultFormBuilder.find_or_create(locale: :fr).form_elements.first.label).to eq 'ADRESSE EMAIL'
    end

    it 'translates the fields to English' do
      expect(DefaultFormBuilder.find_or_create.form_elements.first.label).to eq 'Email Address'
    end

    it 'marks the German form as DE' do
      expect(DefaultFormBuilder.find_or_create(locale: 'de').name).to eq 'Basic (DE)'
    end

    it 'marks the French form as FR' do
      expect(DefaultFormBuilder.find_or_create(locale: 'fr').name).to eq 'Basic (FR)'
    end

    it 'marks the English form as EN' do
      expect(DefaultFormBuilder.find_or_create(locale: :en).name).to eq 'Basic (EN)'
    end
  end

  context 'when form already exists' do
    before { DefaultFormBuilder.find_or_create }

    it "doesn't create a new form" do
      expect do
        DefaultFormBuilder.find_or_create
      end.to_not change { Form.count }.from(1)
    end

    it 'returns existing form' do
      expect(DefaultFormBuilder.find_or_create.name).to eq('Basic (EN)')
    end
  end
end
