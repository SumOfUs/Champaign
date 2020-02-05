# frozen_string_literal: true

require 'rails_helper'

describe 'webhooks' do
  describe 'subscriptions' do
    let(:events) do
      {
        'events' => [
          {
            'id' => 'EVTEST6RQPRR7D',
            'created_at' => '2016-04-20T10:32:34.696Z',
            'resource_type' => 'subscriptions',
            'action' => 'payment_created',
            'links' => {
              'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123'
            },
            'details' => {
              'origin' => 'gocardless',
              'cause' => 'payment_created',
              'description' => 'Payment created by a subscription.'
            },
            'metadata' => {}
          }
        ]
      }.to_json
    end

    let!(:page)         { create(:page) }
    let!(:member)       { create(:member) }
    let!(:action)       { create(:action, member: member, page: page, donation: true, form_data: { amount: 100, currency: 'GBP', payment_provider: 'go_cardless' }) }
    let!(:subscription) { create(:payment_go_cardless_subscription, go_cardless_id: 'index_ID_123', action: action, amount: 100, page: page) }

    before do
      allow(FundingCounter).to receive(:update)
    end

    describe 'with valid signature' do
      let(:headers) do
        {
          'CONTENT_TYPE' => 'application/json',
          'ACCEPT' => 'application/json',
          'HTTP_WEBHOOK_SIGNATURE' => 'eac5bd1740841f39111333d572f525f1f03cdacc04b0ecc43e17a3da4787a011'
        }
      end

      it 'processes events' do
        post('/api/go_cardless/webhook', params: events, headers: headers)
        expect(subscription.reload.aasm_state).to eq('active')
      end

      context 'with missing subscription' do
        it 'stores event' do
          Payment::GoCardless::Subscription.delete_all
          post('/api/go_cardless/webhook', params: events, headers: headers)
          expect(Payment::GoCardless::WebhookEvent.first.resource_id).to eq('index_ID_123')
        end
      end

      context 'with payment_created event' do
        before do
          subscription.transactions.create!(go_cardless_id: 'PM123')
          allow(ChampaignQueue).to receive(:push)
          post('/api/go_cardless/webhook', params: events, headers: headers)
        end

        describe 'transaction' do
          subject { Payment::GoCardless::Transaction.last }

          it 'has correct attributes' do
            expect(
              subject.attributes.symbolize_keys
            ).to include(go_cardless_id: 'payment_ID_123',
                         page_id: page.id,
                         amount: 100,
                         charge_date: Date.new(2016, 4, 20),
                         customer_id: subscription.customer_id,
                         payment_method_id: subscription.payment_method_id,
                         subscription_id: subscription.id)
          end

          it 'is created' do
            expect(
              subject.created?
            ).to be(true)
          end
        end

        describe 'Posting to queue' do
          context 'with existing transaction' do
            it 'posts to queue' do
              expect(ChampaignQueue).to have_received(:push).with(
                { type: 'subscription-payment', params: { recurring_id: 'index_ID_123', trans_id: 'payment_ID_123' } },
                { group_id: /gocardless-subscription:\d+/ }
              )
            end
          end
        end
      end

      context 'with payment failed event from a subscription' do
        let!(:subscription) { create(:payment_go_cardless_subscription, go_cardless_id: 'index_ID_123', action: action, ak_order_id: '1', amount: 100, page: page) }
        let!(:transaction)  do
          create(:payment_go_cardless_transaction,
                 go_cardless_id: 'this_will_fail_123',
                 subscription: subscription)
        end

        let(:events) do
          {
            'events' => [
              {
                'id' => 'EV456',
                'created_at' => '2016-04-20T10:32:34.696Z',
                'resource_type' => 'payments',
                'action' => 'failed',
                'links' => {
                  'payment' => 'this_will_fail_123'
                },
                'details' => {
                  'origin' => 'bank',
                  'cause' => 'mandate_cancelled',
                  'description' => 'Customer cancelled the mandate at their bank branch.',
                  'scheme' => 'bacs',
                  'reason_code' => 'ARRUD-1'
                }
              }
            ]
          }.to_json
        end

        let(:valid) { instance_double(Api::HMACSignatureValidator) }

        before do
          allow(Api::HMACSignatureValidator).to receive(:new).and_return(valid)
          allow(valid).to receive(:valid?).and_return(true)
        end

        it 'posts a failed subscription charge to the queue' do
          expect(ChampaignQueue).to receive(:push).with({
            type: 'subscription-payment-failure',
            params: {
              recurring_id: subscription.go_cardless_id,
              success: 0,
              status: 'failed',
              trans_id: 'this_will_fail_123',
              ak_order_id: subscription.ak_order_id
            }
          },
                                                        { group_id: /gocardless-subscription:\d+/ })
          post('/api/go_cardless/webhook', params: events, headers: headers)
        end
      end
    end

    describe 'with invalid signature' do
      headers = {
        'CONTENT_TYPE' => 'application/json',
        'ACCEPT' => 'application/json',
        'HTTP_WEBHOOK_SIGNATURE' => 'bad_signature'
      }

      it 'responds with 498' do
        headers = {
          'CONTENT_TYPE' => 'application/json',
          'ACCEPT' => 'application/json',
          'HTTP_WEBHOOK_SIGNATURE' => 'not_valid'
        }

        post('/api/go_cardless/webhook', params: events, headers: headers)
        expect(response.status).to eq(427)
      end
    end
  end

  describe 'refund' do
    let(:events) do
      { 'events' => [{ 'id' => 'EVTEST5E573CE7', 'created_at' => '2019-05-27T08:22:51.162Z', 'resource_type' => 'refunds', 'action' => 'created', 'links' => { 'refund' => 'RF0000Z0ED4DJJ' }, 'details' => { 'origin' => 'api', 'cause' => 'refund_created', 'description' => 'The refund has been created, and will be submitted in the next batch.' }, 'metadata' => {} }], 'go_cardless' => { 'events' => [{ 'id' => 'EVTEST5E573CE7', 'created_at' => '2019-05-27T08:22:51.162Z', 'resource_type' => 'refunds', 'action' => 'created', 'links' => { 'refund' => 'RF0000Z0ED4DJJ' }, 'details' => { 'origin' => 'api', 'cause' => 'refund_created', 'description' => 'The refund has been created, and will be submitted in the next batch.' }, 'metadata' => {} }] } }.to_json
    end

    let(:headers) do
      {
        'CONTENT_TYPE' => 'application/json',
        'ACCEPT' => 'application/json',
        'HTTP_WEBHOOK_SIGNATURE' => 'eac5bd1740841f39111333d572f525f1f03cdacc04b0ecc43e17a3da4787a011'
      }
    end

    let!(:page)         { create(:page) }
    let!(:member)       { create(:member) }
    let!(:transaction)  do
      VCR.use_cassette('money_from_oxr') do
        create(:payment_go_cardless_transaction, go_cardless_id: 'PM003QV5KJ20TP', amount: 0.66, currency: 'EUR', page: page)
      end
    end
    let!(:transaction2) do
      VCR.use_cassette('money_from_oxr') do
        create(:payment_go_cardless_transaction, go_cardless_id: 'PM003QV5KJ20RP', amount: 8.0, currency: 'EUR', page: page)
      end
    end
    let(:valid) { instance_double(Api::HMACSignatureValidator) }

    before do
      counter = FundingCounter.new(page, transaction.currency, transaction.amount)
      @original_donation = counter.original_amount

      allow(Api::HMACSignatureValidator).to receive(:new).and_return(valid)
      allow(valid).to receive(:valid?).and_return(true)

      VCR.use_cassette('api_go_cardless_refund_event') do
        post('/api/go_cardless/webhook', params: events, headers: headers)
      end
    end

    it 'should update refund details' do
      transaction.reload

      expect(response.status).to eq(200)
      expect(transaction.refund).to be true
      expect(transaction.refunded_at.to_s).to eq '2019-03-11 10:35:58 UTC'
      expect(transaction.refund_transaction_id).to eq 'RF0000Z0ED4DJJ'
      expect(transaction.amount_refunded).to eq 0.66
    end

    it 'should have initial total donations as 10.65 USD' do
      expect(@original_donation.to_f).to eq 10.65
    end

    it 'should decrement the total donations by 984 cents' do
      expect(page.reload.total_donations.to_f).to eql 984.0
    end
  end
end
