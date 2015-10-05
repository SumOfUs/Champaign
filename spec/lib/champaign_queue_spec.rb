require 'rails_helper'

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
      after  { ENV['AK_PROCESSOR_URL'] = nil }

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

