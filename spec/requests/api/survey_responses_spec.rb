# frozen_string_literal: true

require 'rails_helper'

describe 'api/pages/:id/survey_responses', type: :request do
  let!(:page) { create(:page, :published) }
  let!(:plugins_survey) { create(:plugins_survey, page: page) }
  let!(:form) { create(:form_with_name_email_and_country, formable: plugins_survey) }

  describe 'POST survey_responses' do
    context 'given the form is valid' do
      let(:params) do
        {
          name: 'Bob',
          email: 'b@test.com',
          country: 'AR',
          form_id: form.id
        }
      end

      it 'returns a successful response' do
        post "/api/pages/#{page.id}/survey_responses", params: params
        expect(response).to be_successful
      end

      it 'creates a new action and sets the form data submitted' do
        expect do
          post "/api/pages/#{page.id}/survey_responses", params: params
        end.to change(Action, :count).by(1)

        action = Action.last
        expect(action.page_id).to eq page.id
        expect(action.form_data).to include(
          'name' => 'Bob',
          'email' => 'b@test.com',
          'country' => 'AR'
        )
      end

      context "given a member with the passed email doesn't exist" do
        it 'creates a member and assigns it to the action' do
          expect do
            post "/api/pages/#{page.id}/survey_responses", params: params
          end.to change(Member, :count).by(1)

          action = Action.last
          expect(action.member.email).to eq 'b@test.com'
        end
      end

      context 'given a member with the passed email already exists' do
        let!(:member) { create(:member, email: 'b@test.com') }
        it 'assigns the member to the created action' do
          post "/api/pages/#{page.id}/survey_responses", params: params
          action = Action.last
          expect(action.member_id).to eq member.id
        end
      end
    end

    context 'given the form is invalid' do
      let(:params) do
        {
          country: 'AR',
          form_id: form.id
        }
      end

      it 'returns 422 and an error message' do
        post "/api/pages/#{page.id}/survey_responses", params: params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['errors']['email']).to include('is required')
      end
    end

    context 'given that the user has previously responded to the same survey' do
      let!(:form_2) do
        create(:form, formable: plugins_survey).tap do |f|
          create :form_element, form: f, name: 'phone', label: 'Phone number', data_type: 'phone', required: true
        end
      end

      let(:form_params) do
        {
          email: 'l@test.com',
          name: 'Lucy',
          country: 'AR',
          form_id: form.id
        }
      end

      let(:form_2_params) do
        {
          phone: '123456',
          form_id: form_2.id
        }
      end

      it 'updates the existing action' do
        post "/api/pages/#{page.id}/survey_responses", params: form_params
        expect(response).to be_successful
        @action = Action.last

        post "/api/pages/#{page.id}/survey_responses", params: form_2_params
        expect(response).to be_successful

        @action.reload
        expect(@action.form_data).to include(
          'email' => 'l@test.com',
          'name' => 'Lucy',
          'country' => 'AR',
          'phone' => '123456'
        )
      end
    end
  end
end
