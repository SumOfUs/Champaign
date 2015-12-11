require 'rails_helper'

describe "Api Actions" do
  let(:sqs_client) { double }

  before do
    allow(Aws::SQS::Client).to receive(:new){ sqs_client }
    allow(sqs_client).to receive(:send_message)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
  end

  describe "creating" do
    let(:page) { create(:page) }
    let(:form) { create(:form_with_email) }

    it "Posts action to SQS Queue" do
      post "/api/pages/#{page.id}/actions", email: "hello@example.com", form_id: form.id

      expected_params = {
        queue_url: 'http://example.com',

        message_body: {
          type: "action",
          params: {
            slug: page.slug,
            body: {
              email: "hello@example.com",
              page_id: page.id.to_s,
              form_id: form.id.to_s
            }
          }
        }.to_json
      }

      expect(sqs_client).to have_received(:send_message).with(expected_params)
      expect(Action.count).to eq(1)
    end
  end
end

