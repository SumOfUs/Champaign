# frozen_string_literal: true

require 'rails_helper'

describe ChampaignQueue::Clients::Sqs do
  context 'with SQS_QUEUE_URL' do
    let(:resp_body) do
      %(<?xml version="1.0"?>
          <SendMessageResponse xmlns="http://queue.amazonaws.com/doc/2012-11-05/">
            <SendMessageResult>
              <MessageId>918aba5a-b70f-4e31-9905-ba02000fcdaa</MessageId>
              <MD5OfMessageBody>9bb58f26192e4ba00f01e2e7b136bbd8</MD5OfMessageBody>
            </SendMessageResult>
            <ResponseMetadata>
              <RequestId>cd1c9703-d46f-555b-a927-d94c5e569d55</RequestId>
            </ResponseMetadata>
        </SendMessageResponse>)
    end

    let(:request_body) { 'Action=SendMessage&DelaySeconds=0&MessageBody=%7B%22foo%22%3A%22bar%22%7D&MessageGroupId=abc&QueueUrl=https%3A%2F%2Fsqs.us-east-1.amazonaws.com%2F679051310897%2Fdemo&Version=2012-11-05' }
    let(:request_uri)  { 'https://sqs.us-east-1.amazonaws.com/679051310897/demo' }

    before do
      Settings.sqs_queue_url = request_uri

      # Set some fake credentials for AWS.
      Aws.config.update(region: 'us-west-2', credentials: Aws::Credentials.new('fake', 'password'))

      stub_request(:post, request_uri)
        .with(body: request_body)
        .to_return(status: 200, body: resp_body)
    end

    it 'delivers payload to AWS SQS Queue' do
      Timecop.freeze('2015/01/01') do
        resp = ChampaignQueue::Clients::Sqs.push({ foo: :bar }, { group_id: 'abc' })

        expect(resp.message_id).to eq('918aba5a-b70f-4e31-9905-ba02000fcdaa')
      end
    end
  end

  context 'without SQS_QUEUE_URL' do
    before do
      Settings.sqs_queue_url = nil
    end

    it 'does not deliver payload to AWS SQS Queue' do
      expect_any_instance_of(Aws::SQS::Client).to_not receive(:send_message)
      ChampaignQueue::Clients::Sqs.push({ foo: :bar }, { group_id: 'abc' })
    end
  end
end
