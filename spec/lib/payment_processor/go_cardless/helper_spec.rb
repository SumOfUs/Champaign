# frozen_string_literal: true

require 'rails_helper'

describe PaymentProcessor::GoCardless::Helper do
  describe '.next_available_date' do
    subject { PaymentProcessor::GoCardless::Helper }

    context 'day has not passed' do
      it 'returns current month' do
        Timecop.freeze('5 May') do
          expect(subject.next_available_date(6)).to eq(Date.parse('6 May'))
        end
      end
    end

    context 'day is today' do
      it 'returns with following month' do
        Timecop.freeze('5 May') do
          expect(subject.next_available_date(5)).to eq(Date.parse('5 June'))
        end
      end
    end

    context 'day has passed' do
      it 'returns with following month' do
        Timecop.freeze('5 May') do
          expect(subject.next_available_date(4)).to eq(Date.parse('4 June'))
        end
      end
    end

    context 'invalid day' do
      it 'raises argument error' do
        expect do
          subject.next_available_date(32)
        end.to raise_error(ArgumentError, 'invalid date')
      end
    end
  end
end
