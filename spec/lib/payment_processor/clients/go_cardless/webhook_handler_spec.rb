require 'rails_helper'
require "openssl"

module PaymentProcessor::Clients::GoCardless
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

  describe WebhookHandler do
    describe "Mandates" do

    end

    describe "Payments" do

    end

    describe "Payouts" do

    end

    describe "Subscriptions" do

    end
  end
end
