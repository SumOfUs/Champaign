require 'champaign_queue'

describe ChampaignQueue, :sqs do

  before do
    # send stuff to the correct (fake) address
    ChampaignQueue.client.config.endpoint = $fake_sqs.uri
    # Queue name MUST correspond to the queue name of your AWS SQS queue!
    ChampaignQueue.client.create_queue(queue_name: 'post_test')
  end

  let!(:campaign_page) {
    create(:page,
           language: build(:language),
           campaign: build(:campaign)
    )
  }
  context 'when pushing a new campaign page object to the message queue', :sqs do
    let(:params) {campaign_page.as_json}
    let(:expected_params) {params.to_json}
    it 'adds an object to the queue that corresponds to that page' do
      ChampaignQueue::SqsPusher.push(params)
      results = ChampaignQueue::SqsPoller.poll
      expect(results.messages.first.body).to eq(expected_params)
    end
  end
end
