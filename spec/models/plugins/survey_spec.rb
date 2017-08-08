# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_surveys
#
#  id           :integer          not null, primary key
#  page_id      :integer
#  active       :boolean          default("false")
#  ref          :string
#  created_at   :datetime
#  updated_at   :datetime
#  auto_advance :boolean          default("true")
#

require 'rails_helper'

describe Plugins::Survey do
  let(:survey) { create :plugins_survey }
  let(:french) { create :language, code: 'fr' }
  let(:german) { create :language, code: 'de' }

  describe 'auto-creation of email field' do
    { de: 'E-MAIL', en: 'Email Address', fr: 'Adresse email' }.each_pair do |locale, label|
      it "automatically adds a form with an email field labeled in #{locale}" do
        page = create :page, language: (create :language, code: locale)
        survey = Plugins::Survey.new(page: page)
        expect(survey.save).to eq true
        expect(survey.forms.size).to eq 1
        expect(survey.forms.first.reload.form_elements.size).to eq 1
        el = survey.forms.first.form_elements.first
        expect(el.name).to eq 'email'
        expect(el.data_type).to eq 'email'
        expect(el.required).to eq true
        expect(el.label).to eq label
      end
    end
  end

  describe 'required_form_elements' do
    # this counts on the functionality spec'd above, that the survey auto-creates its own form
    # with an email field on an after_create hook
    let!(:form1) { create :form, formable: survey }

    it 'does not require any of the email fields if there are two in the same form' do
      create :form_element, name: 'email', data_type: 'email', form: survey.forms.first
      expect(survey.required_form_elements).to eq []
    end

    it 'does not require any of the email fields if there are two in different forms' do
      form2 = create :form, formable: survey
      create :form_element, name: 'email', data_type: 'email', form: form2
      expect(survey.reload.required_form_elements).to eq []
    end

    it 'does not require anything if the required fields are already missing' do
      FormElement.destroy_all
      create :form_element, name: 'action_survey_hair_color', form: form1
      expect(survey.required_form_elements).to eq []
    end

    it 'requires the email field if there is only one' do
      create :form, formable: survey
      expect(survey.required_form_elements).to eq FormElement.where(form_id: survey.forms.first.id).map(&:id)
    end
  end
end
