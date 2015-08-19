require 'rails_helper'

describe ChampaignQueue::Clients::Sqs do
  context "with SQS_QUEUE_URL" do
    xit "delivers payload to AWS SQS Queue" do

      expected_arguments = {
        queue_url: "http://example.com",
        message_body: {foo: :bar}.to_json
      }

      expect_any_instance_of(Aws::SQS::Client).to(
        receive(:send_message).with( expected_arguments )
      )

      ChampaignQueue::Clients::Sqs.push({foo: :bar})
    end
  end

  context "without SQS_QUEUE_URL" do
    before do
      allow(ENV).to receive(:[]).with("SQS_QUEUE_URL"){ nil }
    end

    it "does not deliver payload to AWS SQS Queue" do
      expect_any_instance_of(Aws::SQS::Client).to_not receive(:send_message)

      ChampaignQueue::Clients::Sqs.push({foo: :bar})
    end
  end
end
