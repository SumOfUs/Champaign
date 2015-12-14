require 'rails_helper'

module PaymentProcessor
  module Clients
    module Braintree
      describe Subscription do
        describe '.make_subscription' do

          before do
            allow(MerchantAccountSelector).to   receive(:for_currency){ 'merchant_123' }
            allow(SubscriptionPlanSelector).to  receive(:for_currency){ 'plan_123' }
            allow(::Braintree::Subscription).to receive(:create){ subscription }
          end

          let(:store) { nil }
          let(:subscription) { double }

          let(:required_options) do
            {
              price: 100,
              currency: 'USD',
              payment_method_token: '12ax',
              store: store
            }
          end

          def options_without(key)
            required_options.delete(key)
            required_options
          end

          subject { described_class }

          [:payment_method_token, :price, :currency].each do |keyword|
            it "requires a #{keyword}" do
              expect{
                subject.make_subscription(
                  options_without(keyword)
                )
              }.to raise_error(ArgumentError, "missing keyword: #{keyword}")
            end
          end

          it 'creates braintree subscription' do
            expected_arguments = {
              price:                100,
              merchant_account_id:  'merchant_123',
              plan_id:              'plan_123',
              payment_method_token: '12ax'
            }

            expect(::Braintree::Subscription).to receive(:create).with(expected_arguments)

            subject.make_subscription(required_options)
          end

          context 'with store' do
            let(:store) { Payment }

            before do
              allow(Payment).to receive(:write_subscription)
            end

            it 'calls write_subscription on store' do
              expect(Payment).to receive(:write_subscription).with({subscription: subscription})
              subject.make_subscription(required_options)
            end
          end
        end
      end
    end
  end
end


