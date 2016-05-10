require 'rails_helper'

module PaymentProcessor
  module GoCardless
    describe Transaction do
      describe '.make_transaction' do

        before do
          allow(Payment::GoCardless).to receive(:write_transaction).and_return(local_transaction)
          allow(Payment::GoCardless).to receive(:write_customer).and_return(local_customer)
          allow(Payment::GoCardless).to receive(:write_mandate).and_return(local_mandate)
          allow(PaymentProcessor::Currency).to receive(:convert).and_return(double(cents: amount_in_euros*100))

          allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:complete).and_return(completed_flow)
          allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:get).and_return(completed_flow)
          allow_any_instance_of(GoCardlessPro::Services::MandatesService).to receive(:get).and_return(mandate)
          allow_any_instance_of(GoCardlessPro::Services::PaymentsService).to receive(:create).and_return(payment)

          allow(ManageDonation).to receive(:create){ action }
        end

        let(:action) { instance_double('Action', member_id: 2) }
        let(:local_transaction) { instance_double('Payment::GoCardless::Transaction', go_cardless_id: 'PA00000') }
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
        let(:payment) { instance_double('GoCardlessPro::Resources::Payment', id: 'PA00000') }

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

        subject { described_class.make_transaction(required_options) }

        [:amount, :currency, :user, :page_id, :redirect_flow_id, :session_token].each do |keyword|
          it "requires a #{keyword}" do
            expect{
              required_options.delete(keyword)
              described_class.make_transaction(**required_options)
            }.to raise_error(ArgumentError, "missing keyword: #{keyword}")
          end
        end

        describe 'calling the GC SDK' do
          it 'completes the redirect flow with the right params' do
            expect_any_instance_of(
              GoCardlessPro::Services::RedirectFlowsService
            ).to receive(:complete).with('RE00000', params: {session_token: required_options[:session_token]})
            subject
          end

          it "fetches the redirect flow when the flow has already been completed" do
            allow_any_instance_of(
              GoCardlessPro::Services::RedirectFlowsService
            ).to receive(:complete).and_raise(
              GoCardlessPro::InvalidStateError.new({'message' => 'Flow already completed.'})
            )
            expect_any_instance_of(
              GoCardlessPro::Services::RedirectFlowsService
            ).to receive(:get).with('RE00000')
            subject
          end

          it 'creates a transaction with the right params' do
            expect_any_instance_of(
              GoCardlessPro::Services::PaymentsService
            ).to receive(:create).with(
              params: {
                amount: amount_in_euros * 100,
                currency: 'EUR',
                links: { mandate: 'MA00000' },
                metadata: { customer_id: 'CU00000' }
              }
            )
            subject
          end
        end

        describe 'currency' do

          let(:amount_in_usd_cents){ (amount_in_dollars * 100).to_i }

          it 'converts currency to GBP if scheme is BACS' do
            allow(mandate).to receive(:scheme).and_return('bacs')
            expect(PaymentProcessor::Currency).to receive(:convert).with(amount_in_usd_cents, 'GBP', 'USD')
            subject
          end

          it 'converts currency to SEK if scheme is autogiro' do
            allow(mandate).to receive(:scheme).and_return('autogiro')
            expect(PaymentProcessor::Currency).to receive(:convert).with(amount_in_usd_cents, 'SEK', 'USD')
            subject
          end

          it 'converts currency to EUR if scheme is SEPA' do
            allow(mandate).to receive(:scheme).and_return('sepa')
            expect(PaymentProcessor::Currency).to receive(:convert).with(amount_in_usd_cents, 'EUR', 'USD')
            subject
          end
        end

        describe 'bookkeeping' do
          it 'delegates to Payment::GoCardless.write_transaction' do
            expect(Payment::GoCardless).to receive(:write_transaction).with(
              local_transaction.go_cardless_id, amount_in_euros, 'EUR', page_id)
            subject
          end

          it 'delegates to Payment::GoCardless.write_customer' do
            expect(Payment::GoCardless).to receive(:write_customer).with('CU00000', action.member_id)
            subject
          end

          it 'delegates to Payment::GoCardless.write_mandate' do
            expect(Payment::GoCardless).to receive(:write_mandate).with(
              'MA00000', 'sepa', mandate.next_possible_charge_date, local_customer.id
            )
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
              transaction_id: "PA00000",
              is_subscription: false,
              payment_provider: "go_cardless"  
            })
            subject
          end

        end

        describe 'error_container' do
          it 'returns nil on success' do
            builder = subject
            expect(builder.error_container).to eq nil
          end

          it 'returns the GoCardless error when failure' do
            allow_any_instance_of(GoCardlessPro::Services::PaymentsService).to receive(:create).and_raise(gc_error)
            builder = subject
            expect(builder.error_container).to eq(gc_error)
          end
        end

        describe 'action' do
          it 'returns the Action object when successful' do
            builder = subject
            expect(builder.action).to eq action
          end

          it 'returns nil when unsuccessful' do
            allow_any_instance_of(GoCardlessPro::Services::PaymentsService).to receive(:create).and_raise(gc_error)
            builder = subject
            expect(builder.action).to eq nil
          end
        end
      end
    end
  end
end

