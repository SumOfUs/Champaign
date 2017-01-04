require 'rails_helper'

describe 'API::Calls' do
  before do
    allow_any_instance_of(Twilio::REST::Calls).to receive(:create)
  end

  describe "POST /api/pages/:id/call" do
    let!(:page) { create(:page, :with_call_tool) }

    let(:params) do
      {
        call: {
          member_phone_number: "+123456789",
          target_index: 1
        }
      }
    end

    context "given valid params" do
      it "returns successfully" do
        post "/api/pages/#{page.id}/call", params
        expect(response).to have_http_status(:no_content)
      end

      it "creates a call" do
        expect {
          post "/api/pages/#{page.id}/call", params
        }.to change(Call, :count).by(1)

        call = Call.last
        expect(call.page_id).to eq(page.id)
        expect(call.member_phone_number).to eq("+123456789")
        expect(call.target_index).to eq(1)
      end

      it "creates a call on Twilio" do
        expect_any_instance_of(Twilio::REST::Calls)
          .to receive(:create)
          .with(hash_including({
            :from => Settings.calls.default_caller_id,
            :to => "+123456789",
            :url => /twilio\/calls\/\d+\/twiml/
          }))

        post "/api/pages/#{page.id}/call", params
      end
    end

    context "given invalid params" do
      let(:params) do
        {
          call: {
            member_phone_number: "wrong number",
            target_index: 1
          }
        }
      end

      it "returns 422 Unprocessable Entity" do
        post "/api/pages/#{page.id}/call", params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns the error messages" do
        post "/api/pages/#{page.id}/call", params
        expect(response_json['errors']).to be_present
      end
    end
  end
end
