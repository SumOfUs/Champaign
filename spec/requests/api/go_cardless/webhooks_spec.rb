# frozen_string_literal: true
require 'rails_helper'

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

  describe 'with valid signature' do
    let(:headers) do
      {
        'CONTENT_TYPE' => 'application/json',
        'ACCEPT' => 'application/json',
        'HTTP_WEBHOOK_SIGNATURE' => 'eac5bd1740841f39111333d572f525f1f03cdacc04b0ecc43e17a3da4787a011'
      }
    end

    it 'processes events' do
      post('/api/go_cardless/webhook', events, headers)
      expect(subscription.reload.aasm_state).to eq('active')
    end

    context 'with missing subscription' do
      it 'stores event' do
        Payment::GoCardless::Subscription.delete_all
        post('/api/go_cardless/webhook', events, headers)
        expect(Payment::GoCardless::WebhookEvent.first.resource_id).to eq('index_ID_123')
      end
    end

    context 'with payment_created event' do
      before do
        subscription.transactions.create!(go_cardless_id: 'PM123')
        allow(ChampaignQueue).to receive(:push)
        post('/api/go_cardless/webhook', events, headers)
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
            expect(ChampaignQueue).to have_received(:push).with(type: 'subscription-payment', params: { recurring_id: 'index_ID_123' })
          end
        end
      end
    end

    context 'with payment failed event from a subscription' do
      let!(:subscription) { create(:payment_go_cardless_subscription, go_cardless_id: 'index_ID_123', action: action, amount: 100, page: page) }
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

      let(:valid) { instance_double(PaymentProcessor::GoCardless::WebhookSignature) }

      before do
        allow(PaymentProcessor::GoCardless::WebhookSignature).to receive(:new).and_return(valid)
        allow(valid).to receive(:valid?).and_return(true)
      end

      it 'posts a failed subscription charge to the queue' do
        expect(ChampaignQueue).to receive(:push).with({
          type: 'subscription-payment',
          params: {
            # Matches the only string format AK accepts, e.g. "2016-12-22 17:47:42"
            created_at: /\A\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}\z/,
            recurring_id: subscription.go_cardless_id,
            success: 0,
            status: 'failed'
          }
        }, { delay: 120 })
        post('/api/go_cardless/webhook', events, headers)
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

      post('/api/go_cardless/webhook', events, headers)
      expect(response.status).to eq(427)
    end
  end
end
