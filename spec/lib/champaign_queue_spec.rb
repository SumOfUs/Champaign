require 'champaign_queue'

describe ChampaignQueue, :sqs do
  let!(:campaign_page) {
    create(:page,
           widgets: [build(:text_body_widget)],
           language: build(:language),
           campaign: build(:campaign)
    )
  }
  context 'when pushing a new campaign page object to the message queue' do
    let(:params) {campaign_page.as_json}
    it 'adds an object to the queue that corresponds to that page' do
      ChampaignQueue::SqsPusher.push(params)
    end
  end
end
