require 'rails_helper'

module PaymentProcessor
  module Clients
    module Braintree
      describe Transaction do
        describe '.make_transaction' do

          before do
            allow(MerchantAccountSelector).to receive(:for_currency){ '123' }
            allow(::Braintree::Transaction).to receive(:sale){ transaction }
          end

          let(:store) { nil }
          let(:transaction) { double }

          let(:required_options) do
            {
              nonce: 'a_nonce',
              amount: 100,
              currency: 'USD',
              user: { email: "bob@example.com", name: 'foo' }
            }
          end

          def options_without(key)
            required_options.delete(key)
            required_options
          end

          subject { described_class }

          [:nonce, :amount, :currency, :user].each do |keyword|
            it "requires a #{keyword}" do
              expect{
                subject.make_transaction(
                  options_without(keyword)
                )
              }.to raise_error(ArgumentError, "missing keyword: #{keyword}")
            end
          end

          it 'creates braintree sale' do
            expected_arguments = {
              amount: 100,
              payment_method_nonce:       'a_nonce',
              merchant_account_id:        '123',
              options: {
               submit_for_settlement:     true,
               store_in_vault_on_success: true
              },
              customer: {
                full_name:               'foo',
                email:                    'bob@example.com'
              }
            }

            expect(::Braintree::Transaction).to receive(:sale).with(expected_arguments)

            subject.make_transaction(required_options)
          end

          context 'with customer' do
            let(:required_options_with_customer) { required_options.merge(customer: customer) }
            let(:customer) { double(:customer, customer_id: '98') }

            context 'repeat transaction' do
              it 'passes customer_id to Braintree' do
                expect(::Braintree::Transaction).to receive(:sale).
                  with( hash_including(customer_id: '98') )

                subject.make_transaction(required_options_with_customer)
              end
            end
          end
        end
      end
    end
  end
end

