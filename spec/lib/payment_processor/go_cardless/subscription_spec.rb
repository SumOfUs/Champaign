require 'rails_helper'
require_relative 'transaction_and_subscription_examples'

module PaymentProcessor
  module GoCardless
    describe Subscription do
      describe '.make_subscription' do

        before do
          allow(Payment::GoCardless).to receive(:write_subscription).and_return(local_subscription)
          allow(Payment::GoCardless).to receive(:write_customer).and_return(local_customer)
          allow(Payment::GoCardless).to receive(:write_mandate).and_return(local_mandate)
          allow(PaymentProcessor::Currency).to receive(:convert).and_return(double(cents: amount_in_euros*100))

          allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:complete).and_return(completed_flow)
          allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:get).and_return(completed_flow)
          allow_any_instance_of(GoCardlessPro::Services::MandatesService).to receive(:get).and_return(mandate)
          allow_any_instance_of(GoCardlessPro::Services::SubscriptionsService).to receive(:create).and_return(subscription)

          allow(ManageDonation).to receive(:create){ action }
        end

        let(:action) { instance_double('Action', member_id: 2) }
        let(:local_subscription) { instance_double('Payment::GoCardless::Subscription', go_cardless_id: 'SU00000') }
        let(:local_customer) { instance_double('Payment::GoCardless::Customer', id: 7) }
        let(:local_mandate) { instance_double('Payment::GoCardless::PaymentMethod') }

        let(:gc_error) { GoCardlessPro::ValidationError.new('invalid') }

        let(:completed_flow) do
          instance_double('GoCardlessPro::Resources::RedirectFlow', 
            links: double(customer: 'CU00000', mandate: 'MA00000')
          )
        end
        let(:mandate) do
          instance_double('GoCardlessPro::Resources::Mandate',
            id: 'MA00000', scheme: 'sepa', next_possible_charge_date: 1.day.from_now
          )
        end
        let(:subscription) { instance_double('GoCardlessPro::Resources::Subscription', id: 'SU00000') }

        let(:amount_in_dollars){ 12.5 }
        let(:amount_in_euros){ 10.98 }
        let(:page_id) { 1 }
        let(:required_options) do
          {
            amount: amount_in_dollars,
            currency: 'USD',
            user: { email: "bob@example.com", name: 'Bob' },
            page_id: page_id,
            redirect_flow_id: 'RE00000',
            session_token: "4f592f2a-2bc2-4028-8a8c-19b222e2faa7"
          }
        end

        subject { described_class.make_subscription(required_options) }

        include_examples 'transaction and subscription', :make_subscription

        describe 'calling the GC SDK' do
          it 'creates a subscription with the right params' do
            expect_any_instance_of(
              GoCardlessPro::Services::SubscriptionsService
            ).to receive(:create).with(
              params: {
                amount: amount_in_euros * 100,
                currency: 'EUR',
                links: { mandate: 'MA00000' },
                metadata: { customer_id: 'CU00000' },
                name: 'donation',
                interval_unit: 'monthly'
              }
            )
            subject
          end
        end

        describe 'bookkeeping' do
          it 'delegates to Payment::GoCardless.write_subscription' do
            expect(Payment::GoCardless).to receive(:write_subscription).with(
              local_subscription.go_cardless_id, amount_in_euros, 'EUR', page_id)
            subject
          end

          it 'delegates to ManageDonation.create' do
            expect(ManageDonation).to receive(:create).with(params: {
              email: "bob@example.com",
              name: "Bob",
              page_id: page_id,
              amount: amount_in_euros.to_s,
              card_num: "MA00000",
              currency: "EUR",
              subscription_id: "SU00000",
              is_subscription: true,
              payment_provider: "go_cardless",
              recurrence_number: 0,
              card_expiration_date: nil
            })
            subject
          end

        end
      end
    end
  end
end

