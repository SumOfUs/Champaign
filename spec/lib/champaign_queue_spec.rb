require 'spec_helper'
require './lib/champaign_queue'

describe ChampaignQueue do
  describe '.push' do
    context 'with Sqs' do
      before { ENV['AK_PROCESSOR_URL'] = nil }

      it 'delegates to Client::Sqs' do
        expect(ChampaignQueue::Clients::Sqs).
          to receive(:push).with(foo: 'bar')

        ChampaignQueue.push(foo: 'bar')
      end
    end

    context 'with Direct' do
      before { ENV['AK_PROCESSOR_URL'] = "http://example.com" }

      it 'delegates to Client::Direct' do
        expect(ChampaignQueue::Clients::Direct).
          to receive(:push).with(foo: 'bar')

        ChampaignQueue.push(foo: 'bar')
      end
    end
  end
end
