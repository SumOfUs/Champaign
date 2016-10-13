# frozen_string_literal: true
require 'rails_helper'

describe 'api/pages/:id/survey_responses', type: :request do
  let!(:page) { create(:page, :published) }
  let!(:plugins_survey) { create(:plugins_survey, page: page) }
  let!(:form) { create(:form_with_phone_and_country, formable: plugins_survey) }

  describe 'POST survey_responses' do
    context 'given the form is valid' do
      let(:params) do
        {
          phone: '1234567',
          country: 'AR',
          form_id: form.id
        }
      end

      it 'returns a successful response' do
        post "/api/pages/#{page.id}/survey_responses", params
        expect(response).to be_success
      end

      it 'creates a new action and sets the form data submitted' do
        expect do
          post "/api/pages/#{page.id}/survey_responses", params
        end.to change(Action, :count).by(1)

        action = Action.last
        expect(action.page_id).to eq page.id
        expect(action.form_data).to include('survey_phone' => '1234567', 'survey_country' => 'AR')
      end
    end

    context 'given the form is invalid' do
      let(:params) do
        {
          phone: 'wrong phone',
          country: 'AR',
          form_id: form.id
        }
      end

      it 'returns 422 and an error message' do
        post "/api/pages/#{page.id}/survey_responses", params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['errors']['phone']).to include('can only have numbers, dash, plus, and parentheses')
      end
    end

    context 'given the form has an email address' do
      let!(:form) { create(:form_with_email, formable: plugins_survey) }
      let(:params) do
        {
          email: 'a@test.com',
          form_id: form.id
        }
      end

      context "given a member with the passed email doesn't exist" do
        it 'creates a member and assigns it to the action' do
          expect do
            post "/api/pages/#{page.id}/survey_responses", params
          end.to change(Member, :count).by(1)

          action = Action.last

          expect(action.member.email).to eq 'a@test.com'
        end
      end

      context 'given a member with the passed email already exists' do
        let!(:member) { create(:member, email: 'a@test.com') }
        it 'assigns the member to the created action' do
          post "/api/pages/#{page.id}/survey_responses", params
          action = Action.last
          expect(action.member_id).to eq member.id
        end
      end
    end

    context 'given that the user has previously responded to the same survey' do
      let(:form_2) { create(:form_with_email, formable: plugins_survey) }

      let(:form_params) do
        {
          phone: '1234567',
          country: 'AR',
          form_id: form.id
        }
      end

      let(:form_2_params) do
        {
          email: 'a@test.com',
          form_id: form_2.id
        }
      end

      it 'updates the existing action' do
        post "/api/pages/#{page.id}/survey_responses", form_params
        expect(response).to be_success
        @action = Action.last

        post "/api/pages/#{page.id}/survey_responses", form_2_params
        expect(response).to be_success

        @action.reload
        expect(@action.form_data).to include(
          'survey_phone' => '1234567',
          'survey_country' => 'AR',
          'survey_email' => 'a@test.com'
        )
      end
    end
  end
end
