# frozen_string_literal: true

require 'rails_helper'

describe 'API::Calls' do
  before do
    allow(Twilio::REST::Client).to receive_message_chain(:new, :calls, :create)
  end

  describe 'POST /api/pages/:id/call' do
    let!(:page) { create(:page, :with_call_tool) }
    let!(:call_tool) { Plugins::CallTool.find_by_page_id(page.id) }
    let(:target) { Plugins::CallTool.find_by_page_id(page.id).targets.sample }

    context 'given valid params' do
      context 'given a valid akid is passed' do
        let(:params) do
          {
            call: {
              member_phone_number: '+1 343-700-3482',
              target_id: target.id
            },
            akid: '1234.5678.tKK7gX'
          }
        end

        it 'returns successfully' do
          post "/api/pages/#{page.id}/call", params: params
          expect(response).to have_http_status(:no_content)
        end

        it 'creates a call' do
          expect do
            post "/api/pages/#{page.id}/call", params: params
          end.to change(Call, :count).by(1)

          call = Call.last
          expect(call.page_id).to eq(page.id)
          expect(call.member_phone_number).to eq('13437003482')
          expect(call.target).to eq target
        end

        it 'creates a call on Twilio' do
          calls = double
          allow(Twilio::REST::Client).to receive_message_chain(:new, :calls).and_return(calls)
          expect(calls)
            .to receive(:create)
            .with(hash_including(from: call_tool.caller_phone_number.number,
                                 to: '13437003482',
                                 url: %r{/twilio/calls/\d+/start}))

          post "/api/pages/#{page.id}/call", params: params
        end

        let!(:member) { create(:member, actionkit_user_id: '5678') }

        it 'returns successfully' do
          post "/api/pages/#{page.id}/call", params: params
          expect(response).to have_http_status(:no_content)
        end

        it 'creates a call and action assigning the recognized member' do
          post "/api/pages/#{page.id}/call", params: params
          call = Call.last
          expect(call.member).to eq(member)
          expect(call.action.member).to eq(member)
        end
      end
    end

    context 'given invalid params' do
      context 'with akid' do
        let(:params) do
          {
            call: {
              member_phone_number: 'wrong number',
              target_id: target.id
            },
            akid: '1234.5678.tKK7gX'
          }
        end

        it 'returns 422 Unprocessable Entity' do
          post "/api/pages/#{page.id}/call", params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns the error messages' do
          post "/api/pages/#{page.id}/call", params: params
          expect(response_json['errors']).to be_present
        end
      end

      context 'without akid' do
        let(:params) do
          {
            call: {
              member_phone_number: '+1 343-700-3482',
              target_id: target.id
            }
          }
        end

        it 'returns an error message saying that the use of the tool is limited' do
          post "/api/pages/#{page.id}/call", params: params
          expect(response_json['errors'].to_s)
            .to include 'limited to recognized members who enter the website through a campaign email'
        end
      end
    end
  end
end
