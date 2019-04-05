# frozen_string_literal: true

require 'rails_helper'

describe 'form element manipulation' do
  let(:user) { create :user }
  let(:page) { create :page }
  let(:survey) { create :plugins_survey, page: page }

  before :each do
    login_as(user, scope: :user)
  end

  describe 'deleting survey elements' do
    it 'returns an error message instead of deleting the last email' do
      form = survey.forms.first
      el = form.form_elements.first # it should be auto-created
      expect { delete("/forms/#{form.id}/form_elements/#{el.id}") }.not_to change { FormElement.count }
      expect(response.status).to eq 422
      expect(response.body).to eq '{"errors":{"base":["is required for this Survey"]},"name":"form_element"}'
    end

    it 'returns 200 when deleting a normal element' do
      form = survey.forms.first
      el = create :form_element, form: form
      expect { delete("/forms/#{form.id}/form_elements/#{el.id}") }.to change { FormElement.count }.by(-1)
      expect(response.status).to eq 200
      expect(response.body).to eq '{"status":"ok"}'
    end

    describe 'reordering survey forms' do
      let(:desired) { [@form2.id, @form1.id, @form3.id, @form0.id] }

      subject { put "/plugins/surveys/#{survey.id}/sort", params: { form_ids: desired.join(',') } }

      before :each do
        @form0 = survey.forms.first
        @form0.update_attributes(position: 0)
        @form1 = create :form, position: 1, formable: survey
        @form2 = create :form, position: 2, formable: survey
        @form3 = create :form, position: 3, formable: survey
        survey.forms.reload
      end

      it 'can reorder forms based on comma separated IDs' do
        expect(survey.forms.map(&:id)).to eq [@form0.id, @form1.id, @form2.id, @form3.id]
        subject
        expect(survey.forms.reload.map(&:id)).to eq desired
      end

      it 'touches the page when the forms are reordered' do
        expect { subject } .to change { page.reload.cache_key }
      end
    end
  end

  describe 'creating dropdowns' do
    let(:el_params) do
      {
        data_type: 'dropdown',
        label: "What's your favorite flavor?",
        name: 'favorite_flavor',
        many_choices: '',
        choices: [''],
        default_value: '',
        required: '0'
      }
    end

    subject { post "/forms/#{survey.forms.first.id}/form_elements", params: @params }

    it 'creates the dropdowns properly if sent many strings on separate lines with \r\n' do
      survey # for lazy load
      @params = { form_element: el_params.merge(many_choices: "Vanilla\r\nCherry Red\r\nFlave") }
      expect { subject }.to change { FormElement.count }.by 1
      expect(FormElement.last.choices).to eq ['Vanilla', 'Cherry Red', 'Flave']
    end

    it 'creates the dropdowns properly if sent many json objects on separate lines with \r\n' do
      survey # for lazy load
      choices = '{"label": "Cherry Red", "value": "stones"}' + "\r\n" + '{"label": "Flave", "value": "FLAVOR FLAVE"}'
      @params = { form_element: el_params.merge(many_choices: choices) }
      expect { subject }.to change { FormElement.count }.by 1
      expected = [{ label: 'Cherry Red', value: 'stones' }, { label: 'Flave', value: 'FLAVOR FLAVE' }]
      expect(FormElement.last.choices).to eq expected.map(&:stringify_keys)
    end

    it 'lets the many_choices value override the choices value' do
      @params = { form_element: el_params.merge(many_choices: "A\r\nB\r\nC", choices: %w[X Y Z]) }
      subject
      expect(FormElement.last.choices).to eq %w[A B C]
    end

    it 'returns 200 if successfully made the element' do
      @params = { form_element: el_params }
      subject
      expect(response.code).to eq '200'
    end

    it 'returns a JSON error if it could not make the element' do
      survey # for lazy load
      @params = { form_element: el_params.merge(many_choices: "{}\r\n{}"), format: 'js' }
      expect { subject }.not_to change { FormElement.count }
      expect(response.code).to eq '422'
      error = '{"errors":{"choices":["must have a label and value for each dictionary option"]},"name":"form_element"}'
      expect(response.body).to eq error
    end
  end
end
