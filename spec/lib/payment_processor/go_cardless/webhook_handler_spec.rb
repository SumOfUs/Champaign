require 'rails_helper'

module PaymentProcessor::GoCardless
  describe WebhookHandler do
    let(:events) do
      [
        {
          "id"=>"EV0005H3ZZ0PFP",
          "created_at"=>"2016-04-12T13:13:55.356Z",
          "resource_type"=>"mandates",
          "action"=>"submitted",
          "links"=>{"mandate"=>"MD0000PTV0CA1K"},
          "details"=> {
            "origin"=>"gocardless",
            "cause"=>"mandate_submitted",
            "description"=>"The mandate has been submitted to the banks."
          },
          "metadata"=>{}
        },

        {
          "id"=>"EV0005H3ZSREEW",
          "created_at"=>"2016-04-12T13:13:50.266Z",
          "resource_type"=>"mandates",
          "action"=>"created",
          "links"=>{"mandate"=>"MD0000PTV0CA1K"},
          "details"=>{
            "origin"=>"api",
            "cause"=>"mandate_created",
            "description"=>"Mandate created via the API."
          },
          "metadata"=>{}
        },

        {
          "id"=>"EV0005H400GF49",
          "created_at"=>"2016-04-12T13:13:55.392Z",
           "resource_type"=>"mandates",
           "action"=>"active",
           "links"=>{"mandate"=>"MD0000PTV0CA1K"},
           "details"=>{
             "origin"=>"gocardless",
             "cause"=>"mandate_activated",
             "description"=> "The time window after submission for the banks to refuse a mandate has ended without any errors being received, so this mandate is now active."
           },
           "metadata"=>{}
        }
      ]
    end

    describe "ProcessEvents" do
      let(:event) do
        {
          id: "EV0005H3ZZ0PFP",
          resource_type: "mandates",
          action: "submitted",
          details: {
            foo: "bar"
          }
        }.deep_stringify_keys!
      end

      subject{ WebhookHandler::ProcessEvents.new([event]) }

      it 'persists new events to DB' do
        subject.record_processing(event)

        event = Payment::GoCardless::WebhookEvent.first

        expect(
          event.attributes
        ).to include('event_id' => 'EV0005H3ZZ0PFP', 'action' => 'submitted')

        expect(JSON.parse(event.body)).to include( 'details' => {'foo' => 'bar'})
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
            subject.record_processing(event)
            expect(subject.already_processed?(event)).to be(true)
          end
        end
      end
    end

    describe "Mandates" do
      let!(:payment_method) { create(:payment_go_cardless_payment_method, go_cardless_id: 'MD0000PTV0CA1K' ) }

      describe 'general behaviour' do
        before do
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'sets state to appropriate event' do
          expect(payment_method.reload.active?).to be(true)
        end

        it 'persists events just once' do
          expect(
            Payment::GoCardless::WebhookEvent.all.map(&:event_id)
          ).to match( events.map{|e| e['id'] } )
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
          ).to match( events.map{|e| e['id'] }.uniq )
        end

        it 'sets state to appropriate event' do
          expect(payment_method.reload.active?).to be(true)
        end
      end

      describe 'with no active state' do
        before do
          events.delete_if{|a| a['action'] == 'active'}
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'sets state to appropriate event' do
          expect(payment_method.reload.submitted?).to be(true)
        end
      end
    end

    describe "Subscriptions" do
      let!(:payment_method) { create(:payment_go_cardless_payment_method, go_cardless_id: 'MD0000PTV0CA1K' ) }
      let!(:subscription)   { create(:payment_go_cardless_subscription,   go_cardless_id: 'index_ID_123', payment_method: payment_method) }

      let(:events) do
        [
          {"id"=>"EVTESTAV3T2NVP",
              "created_at"=>"2016-04-14T11:27:42.565Z",
              "resource_type"=>"subscriptions",
              "action"=>"created",
              "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
              "details"=>
               {"origin"=>"api",
                "cause"=>"subscription_created",
                "description"=>"Subscription created via the API."},
              "metadata"=>{}},

          {"id"=>"EVTESTJG8GPP7G",
              "created_at"=>"2016-04-14T11:32:20.343Z",
              "resource_type"=>"subscriptions",
              "action"=>"customer_approval_granted",
              "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
              "details"=>
               {"origin"=>"customer",
                "cause"=>"customer_approval_granted",
                "description"=>"The customer granted approval for this subscription"},
              "metadata"=>{}},

          {"id"=>"EVTESTDE3FM5V8",
              "created_at"=>"2016-04-14T11:41:54.311Z",
              "resource_type"=>"subscriptions",
              "action"=>"customer_approval_denied",
              "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
              "details"=>
               {"origin"=>"customer",
                "cause"=>"customer_approval_denied",
                "description"=>"The customer denied approval for this subscription"},
              "metadata"=>{}},

          {"id"=>"EVTEST4VAXTFZD",
              "created_at"=>"2016-04-14T11:43:00.208Z",
              "resource_type"=>"subscriptions",
              "action"=>"payment_created",
              "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
              "details"=>
               {"origin"=>"gocardless",
                "cause"=>"payment_created",
                "description"=>"Payment created by a subscription."},
              "metadata"=>{}},

          {"id"=>"EVTESTX92MH5D4",
              "created_at"=>"2016-04-14T11:46:58.634Z",
              "resource_type"=>"subscriptions",
              "action"=>"cancelled",
              "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
              "details"=>
               {"origin"=>"api",
                "cause"=>"mandate_cancelled",
                "description"=>
                 "The subscription was cancelled because its mandate was cancelled by an API call."},
              "metadata"=>{}}
        ]
      end

      let(:positive_events) do
        events.delete_if{|a| ['cancelled', 'customer_approval_denied'].include? a['action']}
      end


      describe 'general behaviour' do
        before do
          WebhookHandler::ProcessEvents.process(positive_events)
        end

        it 'sets state to appropriate event' do
          expect(subscription.reload.active?).to be(true)
        end

        it 'persists events just once' do
          expect(
            Payment::GoCardless::WebhookEvent.all.map(&:event_id)
          ).to match( events.map{|e| e['id'] } )
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
          ).to match( events.map{|e| e['id'] }.uniq )
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
        let(:events) do
          [
            {"id"=>"EVTESTJG8GPP7G",
              "created_at"=>"2016-04-14T11:32:20.343Z",
              "resource_type"=>"subscriptions",
              "action"=>"customer_approval_granted",
              "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
              "details"=>
               {"origin"=>"customer",
                "cause"=>"customer_approval_granted",
                "description"=>"The customer granted approval for this subscription"},
              "metadata"=>{}},

            {"id"=>"EVTEST4VAXTFZD",
              "created_at"=>"2016-04-14T11:43:00.208Z",
              "resource_type"=>"subscriptions",
              "action"=>"payment_created",
              "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
              "details"=>
               {"origin"=>"gocardless",
                "cause"=>"payment_created",
                "description"=>"Payment created by a subscription."},
              "metadata"=>{}}
          ]
        end

        before do
          WebhookHandler::ProcessEvents.process(events)
        end

        it 'state stays as active' do
          expect(subscription.reload.active?).to be(true)
        end
      end
    end

    describe "Payments" do; end

    describe "Payouts" do; end
  end
end

