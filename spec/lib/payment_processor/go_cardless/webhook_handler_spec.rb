# frozen_string_literal: true

require 'rails_helper'

module PaymentProcessor::GoCardless
  describe WebhookHandler do
    let(:page) { create(:page) }

    let(:events) do
      [
        {
          'id' => 'EV0005H3ZZ0PFP',
          'created_at' => '2016-04-12T13:13:55.356Z',
          'resource_type' => 'mandates',
          'action' => 'submitted',
          'links' => {
            'mandate' => 'MD0000PTV0CA1K'
          },
          'details' => {
            'origin' => 'gocardless',
            'cause' => 'mandate_submitted',
            'description' => 'The mandate has been submitted to the banks.'
          },
          'metadata' => {}
        },

        {
          'id' => 'EV0005H3ZSREEW',
          'created_at' => '2016-04-12T13:13:50.266Z',
          'resource_type' => 'mandates',
          'action' => 'created',
          'links' => { 'mandate' => 'MD0000PTV0CA1K' },
          'details' => {
            'origin' => 'api',
            'cause' => 'mandate_created',
            'description' => 'Mandate created via the API.'
          },
          'metadata' => {}
        },

        {
          'id' => 'EV0005H400GF49',
          'created_at' => '2016-04-12T13:13:55.392Z',
          'resource_type' => 'mandates',
          'action' => 'active',
          'links' => { 'mandate' => 'MD0000PTV0CA1K' },
          'details' => {
            'origin' => 'gocardless',
            'cause' => 'mandate_activated',
            'description' => 'The time window after submission for the banks to refuse a mandate has ended without any errors being received, so this mandate is now active.'
          },
          'metadata' => {}
        }
      ]
    end

    describe 'ProcessEvents' do
      let(:event) do
        {
          id: 'EV0005H3ZZ0PFP',
          resource_type: 'mandates',
          action: 'submitted',
          details: {
            foo: 'bar'
          }
        }.deep_stringify_keys!
      end

      let(:handler) { instance_double(PaymentProcessor::GoCardless::WebhookHandler::Mandate, resource_id: 'MA00000') }

      subject { WebhookHandler::ProcessEvents.new([event]) }

      it 'persists new events to DB' do
        subject.record_processing(event, handler)

        event = Payment::GoCardless::WebhookEvent.first

        expect(
          event.attributes
        ).to include('event_id' => 'EV0005H3ZZ0PFP', 'action' => 'submitted')

        expect(JSON.parse(event.body)).to include('details' => { 'foo' => 'bar' })
      end

      describe 'already_processed?' do
        context 'new event' do
          it 'returns false' do
            expect(subject.already_processed?(event)).to be(false)
          end
        end

        context 'existing event' do
          it 'returns true' do
            expect(subject.already_processed?(event)).to be(false)
            subject.record_processing(event, handler)
            expect(subject.already_processed?(event)).to be(true)
          end
        end
      end
    end

    describe 'Mandates' do
      let!(:payment_method) { create(:payment_go_cardless_payment_method, go_cardless_id: 'MD0000PTV0CA1K') }

      describe 'general behaviour' do
        before do
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'sets updates state on payment method record' do
          expect(payment_method.reload.active?).to be(true)
        end

        it 'persists event' do
          expect(
            Payment::GoCardless::WebhookEvent.first.attributes
          ).to include({
            resource_id: 'MD0000PTV0CA1K',
            resource_type: 'mandates'
          }.stringify_keys)
        end

        it 'persists events just once' do
          expect(
            Payment::GoCardless::WebhookEvent.all.map(&:event_id)
          ).to match_array(events.map { |e| e['id'] })
        end
      end

      describe 'with repeated events' do
        before do
          events.concat(events)
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'persists events just once' do
          expect(
            Payment::GoCardless::WebhookEvent.all.map(&:event_id)
          ).to match_array(events.map { |e| e['id'] }.uniq)
        end

        it 'sets state to appropriate event' do
          expect(payment_method.reload.active?).to be(true)
        end
      end

      describe 'with no active state' do
        before do
          events.delete_if { |a| a['action'] == 'active' }
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'sets state to appropriate event' do
          expect(payment_method.reload.submitted?).to be(true)
        end
      end
    end

    describe 'Non application events' do
      let(:non_applicable_events) do
        [
          { 'id' => 'XEVTESTJG8GPP7I',
            'created_at' => '2016-04-14T11:32:20.343Z',
            'resource_type' => 'payouts',
            'action' => 'customer_approval_granted',
            'links' => { 'payment' => 'payment_ID_1234', 'subscription' => 'index_ID_123' },
            'details' =>
             { 'origin' => 'customer',
               'cause' => 'customer_approval_granted',
               'description' => 'The customer granted approval for this subscription' },
            'metadata' => {} }
        ]
      end

      it 'stores event' do
        WebhookHandler::ProcessEvents.process(non_applicable_events)
        expect(Payment::GoCardless::WebhookEvent.first.attributes).to include({
          event_id: 'XEVTESTJG8GPP7I',
          resource_id: nil
        }.stringify_keys)
      end
    end

    describe 'Subscriptions' do
      let(:pending_first)   { true }
      let(:action)          { create(:action, page: page, form_data: { recurrence_number: 1 }) }
      let!(:payment_method) { create(:payment_go_cardless_payment_method, go_cardless_id: 'MD0000PTV0CA1K') }
      let!(:subscription)   { create(:payment_go_cardless_subscription,   go_cardless_id: 'index_ID_123', payment_method: payment_method, action: action, page: page) }

      let(:events) do
        [
          { 'id' => 'EVTESTAV3T2NVP',
            'created_at' => '2016-04-14T11:27:42.565Z',
            'resource_type' => 'subscriptions',
            'action' => 'created',
            'links' => { 'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123' },
            'details' =>
               { 'origin' => 'api',
                 'cause' => 'subscription_created',
                 'description' => 'Subscription created via the API.' },
            'metadata' => {} },

          { 'id' => 'EVTESTJG8GPP7G',
            'created_at' => '2016-04-14T11:32:20.343Z',
            'resource_type' => 'subscriptions',
            'action' => 'customer_approval_granted',
            'links' => { 'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123' },
            'details' =>
               { 'origin' => 'customer',
                 'cause' => 'customer_approval_granted',
                 'description' => 'The customer granted approval for this subscription' },
            'metadata' => {} },

          { 'id' => 'EVTESTDE3FM5V8',
            'created_at' => '2016-04-14T11:41:54.311Z',
            'resource_type' => 'subscriptions',
            'action' => 'customer_approval_denied',
            'links' => { 'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123' },
            'details' =>
               { 'origin' => 'customer',
                 'cause' => 'customer_approval_denied',
                 'description' => 'The customer denied approval for this subscription' },
            'metadata' => {} },

          { 'id' => 'EVTEST4VAXTFZD',
            'created_at' => '2016-04-14T11:43:00.208Z',
            'resource_type' => 'subscriptions',
            'action' => 'payment_created',
            'links' => { 'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123' },
            'details' =>
               { 'origin' => 'gocardless',
                 'cause' => 'payment_created',
                 'description' => 'Payment created by a subscription.' },
            'metadata' => {} },

          { 'id' => 'EVTESTX92MH5D4',
            'created_at' => '2016-04-14T11:46:58.634Z',
            'resource_type' => 'subscriptions',
            'action' => 'cancelled',
            'links' => { 'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123' },
            'details' =>
               { 'origin' => 'api',
                 'cause' => 'mandate_cancelled',
                 'description' =>
                 'The subscription was cancelled because its mandate was cancelled by an API call.' },
            'metadata' => {} }
        ]
      end

      let(:positive_events) do
        events.delete_if { |a| %w[cancelled customer_approval_denied].include? a['action'] }
      end

      describe 'general behaviour' do
        before do
          allow(ChampaignQueue).to receive(:push)
          WebhookHandler::ProcessEvents.process(positive_events)
        end

        it 'sets state to appropriate event' do
          expect(subscription.reload.active?).to be(true)
        end

        it 'persists events just once' do
          expect(
            Payment::GoCardless::WebhookEvent.all.map(&:event_id)
          ).to match(events.map { |e| e['id'] })
        end
      end

      describe 'with repeated events' do
        before do
          positive_events.concat(positive_events)
          WebhookHandler::ProcessEvents.process(positive_events)
        end

        it 'persists events just once' do
          expect(
            Payment::GoCardless::WebhookEvent.all.map(&:event_id)
          ).to match(events.map { |e| e['id'] }.uniq)
        end

        it 'sets state to appropriate event' do
          expect(subscription.reload.active?).to be(true)
        end
      end

      describe 'with cancelled event' do
        before do
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'sets state to cancelled' do
          expect(subscription.reload.cancelled?).to be(true)
        end
      end

      describe 'with created payment event' do
        let(:first_events) do
          [
            { 'id' => 'EVTESTJG8GPP7G',
              'created_at' => '2016-04-14T11:32:20.343Z',
              'resource_type' => 'subscriptions',
              'action' => 'customer_approval_granted',
              'links' => { 'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123' },
              'details' =>
               { 'origin' => 'customer',
                 'cause' => 'customer_approval_granted',
                 'description' => 'The customer granted approval for this subscription' },
              'metadata' => {} },

            { 'id' => 'EVTEST4VAXTFZD',
              'created_at' => '2016-04-14T11:43:00.208Z',
              'resource_type' => 'subscriptions',
              'action' => 'payment_created',
              'links' => { 'payment' => 'payment_ID_123', 'subscription' => 'index_ID_123' },
              'details' =>
               { 'origin' => 'gocardless',
                 'cause' => 'payment_created',
                 'description' => 'Payment created by a subscription.' },
              'metadata' => {} }
          ]
        end

        let(:second_events) do
          [
            { 'id' => 'XEVTESTJG8GPP7G',
              'created_at' => '2016-04-14T11:32:20.343Z',
              'resource_type' => 'subscriptions',
              'action' => 'customer_approval_granted',
              'links' => { 'payment' => 'payment_ID_1234', 'subscription' => 'index_ID_123' },
              'details' =>
               { 'origin' => 'customer',
                 'cause' => 'customer_approval_granted',
                 'description' => 'The customer granted approval for this subscription' },
              'metadata' => {} },

            { 'id' => 'XEVTEST4VAXTFZD',
              'created_at' => '2016-04-14T11:43:00.208Z',
              'resource_type' => 'subscriptions',
              'action' => 'payment_created',
              'links' => { 'payment' => 'payment_ID_1234', 'subscription' => 'index_ID_123' },
              'details' =>
               { 'origin' => 'gocardless',
                 'cause' => 'payment_created',
                 'description' => 'Payment created by a subscription.' },
              'metadata' => {} }
          ]
        end

        before do
          allow(ChampaignQueue).to receive(:push)
          WebhookHandler::ProcessEvents.process(first_events)
        end

        it 'state stays as active' do
          expect(subscription.reload.active?).to be(true)
        end

        context 'first created payment' do
          it 'posts to queue' do
            expect(ChampaignQueue).to have_received(:push).with(
              { type: 'subscription-payment',
                params: {
                  recurring_id: 'index_ID_123'
                } },
              { group_id: "gocardless-subscription:#{subscription.id}" }
            ).once
          end
        end

        context 'second created payment' do
          before do
            WebhookHandler::ProcessEvents.process(second_events)
          end

          it 'posts to queue' do
            expect(ChampaignQueue).to have_received(:push).with(
              { type: 'subscription-payment',
                params: {
                  recurring_id: 'index_ID_123'
                } },
              { group_id: "gocardless-subscription:#{subscription.id}" }
            ).twice
          end
        end
      end
    end

    describe 'Payments' do
      context 'from subscription' do
        let(:events) do
          [
            { 'id' => 'EV0005XF2PEPV3',
              'created_at' => '2016-05-05T12:42:55.781Z',
              'resource_type' => 'mandates',
              'action' => 'created',
              'links' => { 'mandate' => 'MD0000QSNJZ13N' },
              'details' =>
             { 'origin' => 'api',
               'cause' => 'mandate_created',
               'description' => 'Mandate created via the API.' },
              'metadata' => {} },
            { 'id' => 'EV0005XF2QKCY7',
              'created_at' => '2016-05-05T12:42:56.480Z',
              'resource_type' => 'subscriptions',
              'action' => 'created',
              'links' => { 'subscription' => 'SB00002TX3VY2P' },
              'details' =>
              { 'origin' => 'api',
                'cause' => 'subscription_created',
                'description' => 'Subscription created via the API.' },
              'metadata' => {} },
            { 'id' => 'EV0005XF2RY3Z2',
              'created_at' => '2016-05-05T12:42:56.733Z',
              'resource_type' => 'payments',
              'action' => 'created',
              'links' => { 'subscription' => 'SB00002TX3VY2P', 'payment' => 'PM00019VHGW3W1' },
              'details' =>
              { 'origin' => 'gocardless',
                'cause' => 'payment_created',
                'description' => 'Payment created by a subscription' },
              'metadata' => {} },
            { 'id' => 'EV0005XF2S9FZA',
              'created_at' => '2016-05-05T12:42:56.765Z',
              'resource_type' => 'subscriptions',
              'action' => 'payment_created',
              'links' => { 'payment' => 'PM00019VHGW3W1', 'subscription' => 'SB00002TX3VY2P' },
              'details' =>
              { 'origin' => 'gocardless',
                'cause' => 'payment_created',
                'description' => 'Payment created by a subscription.' },
              'metadata' => {} }
          ]
        end

        let!(:action)         { create(:action, :with_member_and_page) }
        let!(:payment_method) { create(:payment_go_cardless_payment_method, go_cardless_id: 'MD0000QSNJZ13N') }
        let!(:subscription)   { create(:payment_go_cardless_subscription,   go_cardless_id: 'SB00002TX3VY2P', page: page, action: action) }

        before do
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'creates a transaction record' do
          expect(Payment::GoCardless::Transaction.count).to eq(1)
        end
      end
    end
  end
end
