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
end
