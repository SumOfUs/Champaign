require 'rails_helper'

describe "Campaigns", type: :request do
  before do
    login_as(create(:user), scope: :user)
  end

  describe "#create" do
    context "given valid params" do
      let(:params) do
        { campaign: { name: "Super Campaign" } }
      end

      it "creates a new campaign" do
        expect {
          post "/campaigns", params
        }.to change(Campaign, :count).by(1)
      end

      it "redirects to /campaigns" do
        post "/campaigns", params
        expect(response).to redirect_to "/campaigns"
      end

      it "publishes the event" do
        expect(ChampaignQueue).to receive(:push).with({
          name: 'Super Campaign',
          type: 'create_campaign',
          campaign_id: be_a(Integer)
        })
        post "/campaigns", params
      end
    end

    context "given invalid params" do
      let(:params) do
        { campaign: { name: "" } }
      end

      it "returns 422 Unprocessable Entity" do
        post '/campaigns', params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays an error message" do
        post '/campaigns', params
        expect(response.body).to include "There was an error"
      end
    end
  end

end
