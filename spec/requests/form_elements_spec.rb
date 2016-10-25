# frozen_string_literal: true
require 'rails_helper'

describe 'deleting survey elements' do
  let(:user) { instance_double('User', id: '1') }
  let(:page) { create :page }
  let(:survey) { create :plugins_survey, page: page }

  before :each do
    login_as(create(:user), scope: :user)
  end

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

    subject { put "/plugins/surveys/#{survey.id}/sort", form_ids: desired.join(',') }

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
