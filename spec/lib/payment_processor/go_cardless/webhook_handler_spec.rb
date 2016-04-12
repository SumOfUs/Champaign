require 'rails_helper'
require "openssl"

module PaymentProcessor::GoCardless
  class WebhookSignature

    def initialize(secret:, body:, signature:)
      @secret = secret
      @body = body
      @signature = signature
    end

    def valid?
      hexdiest == @signature
    end

    private

    def hexdiest
      OpenSSL::HMAC.hexdigest(digest, @secret, @body)
    end

    def digest
      OpenSSL::Digest.new("sha256")
    end
  end
  class WebhookHandler
    class EventStore

      class << self
        def event_exists?(event)
          if Payment::GoCardless::WebhookEvent.exists?(event_id: event[:id])
            return true
          else
            Payment::GoCardless::WebhookEvent.create(
              event_id: event[:id],
              action: event[:action],
              resource_type: event[:resource_type],
              body: event.to_json
            )

            false
          end
        end
      end
    end
  end

  describe WebhookSignature do
    subject { WebhookSignature.new(secret: secret, signature: signature, body: body) }

    let(:secret) { 'monkey' }
    let(:signature) { "7cf678d62d6732be4130e2b0fc3ad33267d7b4e764e9877eda9bee32c448bd7d" }


    let(:body) do
      "{\"events\":[{\"id\":\"EVTESTEQJN4TSY\",\"created_at\":\"2016-04-11T16:46:13.898Z\",\"resource_type\":\"mandates\",\"action\":\"created\",\"links\":{\"mandate\":\"index_ID_123\"},\"details\":{\"origin\":\"gocardless\",\"cause\":\"mandate_created\",\"description\":\"Mandate created by a bulk change\"},\"metadata\":{}}]}"
    end

    context 'with correct secret' do
      it 'validates signature' do
        expect(subject.valid?).to be(true)
      end
    end

    context 'with incorrect secret' do
      let(:secret) { 'primate' }

      it 'does not validate signature' do
        expect(subject.valid?).to_not be(true)
      end
    end
  end

  describe WebhookHandler::EventStore do
    let(:event) do
      {
        id: "EV0005H3ZZ0PFP",
        rsource_type: "mandates",
        action: "submitted",
        details: {
          foo: "bar"
        }
      }
    end

    subject { PaymentProcessor::GoCardless::WebhookHandler::EventStore }

    it 'persists new events to DB' do
      subject.event_exists?(event)

      event = Payment::GoCardless::WebhookEvent.first

      expect(
        event.attributes
      ).to include('event_id' => 'EV0005H3ZZ0PFP', 'action' => 'submitted')

      expect(JSON.parse(event.body)).to include( 'details' => {'foo' => 'bar'})
    end

    describe '.event_exists?' do
      context 'new event' do
        it 'returns false' do
          expect(subject.event_exists?(event)).to be(false)
        end
      end

      context 'existing event' do
        it 'returns true' do
          subject.event_exists?(event)
          expect(subject.event_exists?(event)).to be(true)
        end
      end
    end
  end

  describe WebhookHandler do
    let(:events) do
      [{"id"=>"EV0005H3ZZ0PFP",
        "created_at"=>"2016-04-12T13:13:55.356Z",
        "resource_type"=>"mandates",
        "action"=>"submitted",
        "links"=>{"mandate"=>"MD0000PTV0CA1K"},
        "details"=>
      {"origin"=>"gocardless",
       "cause"=>"mandate_submitted",
       "description"=>"The mandate has been submitted to the banks."},
       "metadata"=>{}},
      {"id"=>"EV0005H400GF49",
       "created_at"=>"2016-04-12T13:13:55.392Z",
       "resource_type"=>"mandates",
       "action"=>"active",
       "links"=>{"mandate"=>"MD0000PTV0CA1K"},
       "details"=>
      {"origin"=>"gocardless",
       "cause"=>"mandate_activated",
       "description"=>
      "The time window after submission for the banks to refuse a mandate has ended without any errors being received, so this mandate is now active."},
        "metadata"=>{}},
      {"id"=>"EV0005H401H0QV",
       "created_at"=>"2016-04-12T13:13:55.986Z",
       "resource_type"=>"payments",
       "action"=>"submitted",
       "links"=>{"payment"=>"PM00017GFBX9NW"},
       "details"=>
      {"origin"=>"gocardless",
       "cause"=>"payment_submitted",
       "description"=>
      "Payment submitted to the banks. As a result, it can no longer be cancelled."},
        "metadata"=>{}},
      {"id"=>"EV0005H402Z0V0",
       "created_at"=>"2016-04-12T13:13:56.023Z",
       "resource_type"=>"payments",
       "action"=>"confirmed",
       "links"=>{"payment"=>"PM00017GFBX9NW"},
       "details"=>
      {"origin"=>"gocardless",
       "cause"=>"payment_confirmed",
       "description"=>
      "Enough time has passed since the payment was submitted for the banks to return an error, so this payment is now confirmed."},
        "metadata"=>{}}]
    end

    describe "Mandates", :focus do
      let!(:payment_method) { create(:payment_go_cardless_payment_method, go_cardless_id: 'MD0000PTV0CA1K' ) }

      before do
        WebhookHandler.process(events)
      end

      it 'sets state to appropirate event' do
        expect(payment_method.reload.active?).to be(true)
      end
    end

    describe "Payments" do
    end

    describe "Payouts" do
    end

    describe "Subscriptions" do
    end
  end
end

module PaymentProcessor::GoCardless
  class WebhookHandler
    def self.process(events)
      new(events).process
    end

    def initialize(events)
      @events = events
    end

    def process
      @events.each do |event|
        ::PaymentProcessor::GoCardless::WebhookHandler.const_get(event["resource_type"].classify).new(event).process
      end
    end
  end
end

module PaymentProcessor::GoCardless
  class WebhookHandler
    module IsAGcEvent
      def initialize(event)
        @event = event
      end

      def process; end

      def mandate
        @mandate ||= ::Payment::GoCardless::PaymentMethod.find_by(go_cardless_id: mandate_id)
      end

      def mandate_id
        @event['links']['mandate']
      end
    end

    class Mandate
      include IsAGcEvent

      def process
        if mandate.may_run_activate?
          mandate.run_activate!
        end
      end
    end
  end

  class WebhookHandler
    class Payment
      include IsAGcEvent
    end
  end
end

