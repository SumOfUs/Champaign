require 'rails_helper'

describe ChampaignQueue do
  describe '.push' do
    context 'with Sqs' do
      before { Settings.ak_processor_url = nil }

      it 'delegates to Client::Sqs' do
        expect(ChampaignQueue::Clients::Sqs).
          to receive(:push).with(foo: 'bar')

        ChampaignQueue.push(foo: 'bar')
      end
    end

    context 'with Direct' do
      before { Settings.ak_processor_url = "http://example.com" }

      it 'delegates to Client::Direct' do
        expect(ChampaignQueue::Clients::Direct).
          to receive(:push).with(foo: 'bar')

        ChampaignQueue.push(foo: 'bar')
      end

      context 'in production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        end

        it 'always delegates to Client::Sqs' do
          expect(ChampaignQueue::Clients::Sqs).
            to receive(:push).with(foo: 'bar')

          ChampaignQueue.push(foo: 'bar')
        end
      end
    end
  end
end

