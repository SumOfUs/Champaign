# frozen_string_literal: true

require 'rails_helper'

describe 'BackgroindServices' do
  describe 'sync_braintree_refunds' do
    let(:page) { create(:page, publish_status: 'published') }
    let(:refund_ids) {
      %w[pa58afh7 pw4w2sps kpjzcm8t f8b00cv7 peve3se6
         09858t43 grms7qa0 cxfs6r3b]
    }
    let(:transaction_ids) {
      %w[7hye1bz0 m7a8f6v1 fg9v30g8 naxgvz4j
         45zh1tby g68p0rqt 12vk0d01 5w1a2z1g
         7hye1bz0 m7a8f6v1 fg9v30g8 naxgvz4j
         45zh1tby g68p0rqt 12vk0d01 5w1a2z1g]
    }

    context 'with invalid api token' do
      before do
        get '/api/background_services/sync_braintree_refunds'
      end

      it 'should return forbidden error' do
        expect(response.response_code).to eq 403
      end
    end

    context 'with valid api token' do
      before do
        VCR.use_cassette('background_service_sync_braintree_refunds') do
          get '/api/background_services/sync_braintree_refunds', params: nil, headers: { 'X-Api-Key' => '1234' }
        end
      end

      it 'should return status ok' do
        expect(response.response_code).to eq 200
      end

      it 'should return unsynced_ids' do
        expect(response_json['refund_ids_synced']).to eql refund_ids
      end
    end

    context 'service running for second time' do
      before do
        transaction_ids.each do |t|
          create(:payment_braintree_transaction, amount: [20, 30, 50].sample,
                                                 status: 'success', currency: 'USD', transaction_id: t,
                                                 page_id: page.id)
        end

        VCR.use_cassette('background_service_sync_braintree_refunds') do
          get '/api/background_services/sync_braintree_refunds', params: nil, headers: { 'X-Api-Key' => '1234' }
        end

        # run second time
        VCR.use_cassette('background_service_sync_braintree_refunds') do
          get '/api/background_services/sync_braintree_refunds', params: nil, headers: { 'X-Api-Key' => '1234' }
        end
      end

      it 'should return unsynced_ids' do
        expect(response_json['refund_ids_synced']).to eql []
      end
    end
  end
end
