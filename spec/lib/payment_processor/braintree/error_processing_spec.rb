# frozen_string_literal: true

require 'rails_helper'

module PaymentProcessor
  module Braintree
    describe ErrorProcessing do
      subject { described_class.new(braintree_transaction_result) }

      describe '#process' do
        let(:error_81801) { double('81801', message: 'user error', code: '81801', attribute: 'amount') }
        let(:error_99999) { double('99999', message: 'no merchant account!', code: '99999', attribute: 'merchant_id') }

        let(:braintree_transaction_result) { double(:transaction_result, transaction: double(:transaction, status: ''), errors: errors) }

        context 'with user errors' do
          let(:errors) { [error_81801, error_99999] }

          it 'returns user error' do
            expect(subject.process).to eq([error_81801])
          end
        end

        context 'without user error' do
          let(:errors) { [error_99999] }

          it 'raises braintree errors' do
            expect do
              subject.process
            end.to raise_error(
              ::Braintree::ValidationsFailed, /no merchant account/
            )
          end
        end
      end
    end
  end
end
