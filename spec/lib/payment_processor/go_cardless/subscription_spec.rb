# frozen_string_literal: true
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
          allow(PaymentProcessor::Currency).to receive(:convert).and_return(double(cents: amount_in_euros * 100))

          allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:complete).and_return(completed_flow)
          allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:get).and_return(completed_flow)
          allow_any_instance_of(GoCardlessPro::Services::MandatesService).to receive(:get).and_return(mandate)
          allow_any_instance_of(GoCardlessPro::Services::CustomerBankAccountsService).to receive(:get).and_return(bank_account)
          allow_any_instance_of(GoCardlessPro::Services::SubscriptionsService).to receive(:create).and_return(subscription)

          allow(ManageDonation).to receive(:create) { action }
        end

        let(:action) { instance_double('Action', member_id: 2, id: 1234) }
        let(:local_subscription) { instance_double('Payment::GoCardless::Subscription', go_cardless_id: 'SU00000', id: 567) }
        let(:local_customer) { instance_double('Payment::GoCardless::Customer', id: 7) }
        let(:local_mandate) { instance_double('Payment::GoCardless::PaymentMethod', id: 543) }

        let(:gc_error) { GoCardlessPro::ValidationError.new(message: 'invalid') }

        let(:completed_flow) do
          instance_double('GoCardlessPro::Resources::RedirectFlow',
                          links: double(customer: 'CU00000', mandate: 'MA00000', customer_bank_account: 'BA00000'))
        end

        let(:mandate) do
          instance_double('GoCardlessPro::Resources::Mandate',
                          id: 'MA00000', scheme: 'sepa', next_possible_charge_date: 1.day.from_now.to_date.to_s, reference: 'SOU-00000')
        end

        let(:bank_account) do
          instance_double('GoCardlessPro::Resources::CustomerBankAccount',
                          id: 'BA00000', bank_name: 'BARCLAYS', account_number_ending: '11')
        end

        let(:subscription) { instance_double('GoCardlessPro::Resources::Subscription', id: 'SU00000') }

        let(:amount_in_dollars) { 12.5 }
        let(:amount_in_euros) { 10.98 }
        let(:page_id) { 1 }
        let(:required_options) do
          {
            amount: amount_in_dollars,
            currency: 'USD',
            user: { email: 'bob@example.com', name: 'Bob' },
            page_id: page_id,
            redirect_flow_id: 'RE00000',
            session_token: '4f592f2a-2bc2-4028-8a8c-19b222e2faa7'
          }
        end

        subject { described_class.make_subscription(required_options) }

        include_examples 'transaction and subscription', :make_subscription

        describe 'charge date' do
          subject { described_class.make_subscription(required_options) }

          let(:amount_in_gbp) { 11.11 }
          let(:completed_gbp_flow) do
            instance_double('GoCardlessPro::Resources::RedirectFlow',
                            links: double(customer: 'CU00000', mandate: 'MA9999', customer_bank_account: 'BA00000'))
          end
          let(:gbp_mandate) do
            instance_double('GoCardlessPro::Resources::Mandate',
                            id: 'MA9999', scheme: 'bacs', next_possible_charge_date: '2016-06-20', reference: 'SOU-00000')
          end
          let(:gbp_options) do
            {
              amount: amount_in_gbp,
              currency: 'GBP',
              user: { email: 'bob@example.com', name: 'Bob' },
              page_id: page_id,
              redirect_flow_id: 'RE00000',
              session_token: '4f592f2a-2bc2-4028-8a8c-19b222e2faa7'
            }
          end

          before do
            allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:complete).and_return(completed_gbp_flow)
            allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:get).and_return(completed_gbp_flow)
            allow_any_instance_of(GoCardlessPro::Services::MandatesService).to receive(:get).and_return(gbp_mandate)
            allow(PaymentProcessor::Currency).to receive(:convert).and_return(double(cents: amount_in_gbp * 100))
          end

          it 'creates a subscription with the right params and charge date' do
            expect_any_instance_of(
              GoCardlessPro::Services::SubscriptionsService
            ).to receive(:create).with(
              params: {
                amount: amount_in_gbp * 100,
                currency: 'GBP',
                links: { mandate: 'MA9999' },
                metadata: { customer_id: 'CU00000' },
                name: 'donation',
                interval_unit: 'monthly',
                # Get charge day from the Settings class for GBP donations.
                start_date: "2016-06-#{Settings.gocardless.gbp_charge_day}"
              }
            )
            described_class.make_subscription(gbp_options)
          end

          it 'uses the gbp charge day that is specified in the Settings class' do
            Settings.gocardless.gbp_charge_day = '08'

            expect_any_instance_of(
              GoCardlessPro::Services::SubscriptionsService
            ).to receive(:create).with(
              params: {
                amount: amount_in_gbp * 100,
                currency: 'GBP',
                links: { mandate: 'MA9999' },
                metadata: { customer_id: 'CU00000' },
                name: 'donation',
                interval_unit: 'monthly',
                # Get charge day from the Settings class for GBP donations.
                start_date: '2016-07-08'
              }
            )
            described_class.make_subscription(gbp_options)
          end

          it 'uses the next possible charge date of the mandate if GBP charge date is not defined' do
            Settings.gocardless.gbp_charge_day = nil

            expect_any_instance_of(
              GoCardlessPro::Services::SubscriptionsService
            ).to receive(:create).with(
              params: {
                amount: amount_in_gbp * 100,
                currency: 'GBP',
                links: { mandate: 'MA9999' },
                metadata: { customer_id: 'CU00000' },
                name: 'donation',
                interval_unit: 'monthly',
                start_date: gbp_mandate.next_possible_charge_date
              }
            )
            described_class.make_subscription(gbp_options)
          end
        end

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
                interval_unit: 'monthly',
                start_date: 1.day.from_now.to_date.to_s
              }
            )
            subject
          end
        end

        describe 'bookkeeping' do
          it 'delegates to Payment::GoCardless.write_subscription' do
            expect(Payment::GoCardless).to receive(:write_subscription).with(
              local_subscription.go_cardless_id, amount_in_euros, 'EUR', page_id, action.id, local_customer.id, local_mandate.id
            )
            subject
          end

          it 'delegates to ManageDonation.create' do
            expect(ManageDonation).to receive(:create).with(params: {
              email: 'bob@example.com',
              name: 'Bob',
              page_id: page_id,
              amount: amount_in_euros.to_s,
              card_num: 'MA00000',
              currency: 'EUR',
              subscription_id: 'SU00000',
              is_subscription: true,
              payment_provider: 'go_cardless',
              recurrence_number: 0,
              card_expiration_date: nil,
              mandate_reference: 'SOU-00000',
              bank_name: 'BARCLAYS',
              account_number_ending: '11'
            })
            subject
          end
        end
      end
    end
  end
end
