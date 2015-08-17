require 'spec_helper'
require './lib/champaign_queue'

describe ChampaignQueue do
  describe '.push' do
    it 'delegates to Client::Sqs' do
      expect(ChampaignQueue::Clients::Sqs).
        to receive(:push).with(foo: 'bar')

      ChampaignQueue.push(foo: 'bar')
    end
  end
end
