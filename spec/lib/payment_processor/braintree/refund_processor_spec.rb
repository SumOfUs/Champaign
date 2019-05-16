# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'default_transactions' do |_parameter|
  let(:page) { create(:page, publish_status: 'published') }
  before do
    @transaction_data = {
      '17a8f6v1' => 100.0, 'm7a8f6v1' => 500.0,
      'fg9v30g8' => 25.0, 'naxgvz4j' => 100.0, '45zh1tby' => 25.0
    }

    @transaction_data.each do |x, v|
      create(:payment_braintree_transaction, amount: v, status: 'success',
                                             currency: 'USD', transaction_id: x, page_id: page.id)
    end
  end
end

module PaymentProcessor
  module Braintree
    describe RefundTracker do
      describe 'before sync' do
        include_examples 'default_transactions'

        it 'should increment the total_donations' do
          expect(page.reload.total_donations.to_f).to eql 75_000.0
        end

        it 'should set default start date as 6 months from current date' do
          @tracker = PaymentProcessor::Braintree::RefundTracker.new
          date = 6.months.ago.strftime('%Y-%m-%d')
          expect(@tracker.start_date).to eql date
        end
      end

      describe 'post sync' do
        include_examples 'default_transactions'

        before do
          VCR.use_cassette('refund_tracker_braintree_refunded_transactions') do
            @tracker = PaymentProcessor::Braintree::RefundTracker.new
            @tracker.sync
          end
        end

        it 'should decrement the total_donations' do
          @tracker.unsynced_transactions.collect { |x| x[:amount].to_f }.sum
          page.reload.total_donations
          expect(page.reload.total_donations.to_f).to eql 10_000.0
        end

        it 'should match refund_ids' do
          expect(@tracker.refund_ids).to match_array(%w[peve3se6 09858t43 grms7qa0 cxfs6r3b])
        end

        it 'should have empty synced_ids' do
          expect(@tracker.synced_ids).to be_empty
        end

        it 'should fetch the details of all unsynced transactions' do
          transaction_ids = @tracker.unsynced_transactions.collect { |x| x[:refunded_transaction_id] }
          ids = @transaction_data.keys - ['17a8f6v1']
          expect(transaction_ids).to match_array(ids)
        end
      end

      describe 'post sync with previous synced refund records' do
        include_examples 'default_transactions'

        before do
          VCR.use_cassette('refund_tracker_braintree_refunded_transactions') do
            @tracker = PaymentProcessor::Braintree::RefundTracker.new
            @tracker.sync
          end

          # run the sync operation second time
          VCR.use_cassette('refund_tracker_braintree_refunded_transactions') do
            @new_tracker = PaymentProcessor::Braintree::RefundTracker.new
            @new_tracker.sync
          end
        end

        it 'should not update the total_donations ' do
          expect(page.reload.total_donations.to_f).to eql 10_000.0
        end

        it 'should yet fetch the synced_ids' do
          expect(@new_tracker.synced_ids).to match_array(%w[peve3se6 09858t43 grms7qa0 cxfs6r3b])
        end

        it 'should yet fetch all the refund ids return by Braintree' do
          expect(@new_tracker.refund_ids).to match_array(%w[peve3se6 09858t43 grms7qa0 cxfs6r3b])
        end

        it 'should not have any transaction to update' do
          transaction_ids = @new_tracker.unsynced_transactions.collect { |x| x[:refunded_transaction_id] }
          expect(transaction_ids).to be_empty
        end
      end

      describe 'filter based on date' do
        before do
          VCR.use_cassette('refund_tracker_braintree_refunded_transactions_with_date_range') do
            date = Time.now.strftime('%Y-%m-%d')
            @tracker = PaymentProcessor::Braintree::RefundTracker.new(date)
            @tracker.sync
          end
        end

        it 'should have empty refund_ids' do
          expect(@tracker.refund_ids).to be_empty
        end
      end
    end
  end
end
