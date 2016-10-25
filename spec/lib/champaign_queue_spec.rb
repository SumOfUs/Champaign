# frozen_string_literal: true
require 'rails_helper'

describe ChampaignQueue do
  describe '.push' do
    context 'in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'delegates to Client::Sqs' do
        expect(ChampaignQueue::Clients::Sqs)
          .to receive(:push).with({ foo: 'bar' }, {})

        ChampaignQueue.push(foo: 'bar')
      end
    end

    context 'not in production' do
      it 'does nothing' do
        expect(ChampaignQueue::Clients::Sqs)
          .to_not receive(:push)

        ChampaignQueue.push(foo: 'bar')
      end
    end
  end
end
