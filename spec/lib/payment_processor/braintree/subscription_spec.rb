# frozen_string_literal: true
require 'rails_helper'

module PaymentProcessor
  module Braintree
    describe Subscription do
      describe '.make_subscription' do
        let(:required_options) do
          {
            amount: '437.14',
            currency: 'AUD',
            nonce: '12ax',
            page_id: '12',
            user: {
              email: 'bob.loblaw@law-blog.org',
              name: 'Bob Loblaw',
              country: 'AU'
            }
          }
        end
        let(:action) { instance_double('Action', member_id: 654, id: 77) }
        let(:customer_token) { 'asdfghjkl' }
        let(:payment_method_token) { 'qwertyuiop' }
        let(:customer_success) { instance_double('Braintree::SuccessResult', success?: true, customer: double(payment_methods: [double(token: customer_token)])) }
        let(:payment_success) { instance_double('Braintree::SuccessResult', success?: true, payment_method: double(token: payment_method_token)) }
        let(:subscription_success) { instance_double('Braintree::SuccessResult', success?: true) }
        let(:failure) { instance_double('Braintree::ErrorResult', success?: false) }

        subject { described_class }

        before :each do
          allow(Payment::Braintree).to receive(:write_customer)
          allow(Payment::Braintree).to receive(:write_subscription)
          allow(::Braintree::Customer).to receive(:update)
          allow(::Braintree::Customer).to receive(:create)
          allow(::Braintree::PaymentMethod).to receive(:create)
          allow(::Braintree::Subscription).to receive(:create)
          allow(ManageBraintreeDonation).to receive(:create).and_return(action)
          allow(SubscriptionPlanSelector).to receive(:for_currency).and_return('AUD')
          allow(MerchantAccountSelector).to receive(:for_currency).and_return('AUD')
        end

        describe 'parameters' do
          [:nonce, :amount, :currency, :user, :page_id].each do |keyword|
            it "requires a #{keyword}" do
              expect do
                required_options.delete(keyword)
                subject.make_subscription(**required_options)
              end.to raise_error(ArgumentError, "missing keyword: #{keyword}")
            end
          end
        end

        describe 'customer exists' do
          let!(:customer) { create :payment_braintree_customer, email: required_options[:user][:email] }
          let(:customer_options) do
            {
              first_name: 'Bob',
              last_name: 'Loblaw',
              email: 'bob.loblaw@law-blog.org'
            }
          end
          let(:payment_method_options) do
            {
              payment_method_nonce: required_options[:nonce],
              customer_id: customer.customer_id,
              billing_address: {
                first_name: 'Bob',
                last_name: 'Loblaw',
                country_code_alpha2: 'AU'
              }
            }
          end
          let(:subscription_options) do
            {
              payment_method_token: payment_method_token,
              plan_id: 'AUD',
              price: '437.14',
              merchant_account_id: 'AUD'
            }
          end

          describe 'but it fails to update' do
            before :each do
              allow(::Braintree::Customer).to receive(:update).and_return(failure)
              @builder = subject.make_subscription(required_options)
            end

            it 'passes the right params to Braintree::Customer.update' do
              expect(::Braintree::Customer).to have_received(:update).with(customer.customer_id, customer_options)
            end

            it 'does not call any other Braintree methods' do
              expect(::Braintree::Customer).not_to have_received(:create)
              expect(::Braintree::PaymentMethod).not_to have_received(:create)
              expect(::Braintree::Subscription).not_to have_received(:create)
            end

            it 'is not successful' do
              expect(@builder.success?).to be(false)
            end

            it "has '#action' as nil" do
              expect(@builder.action).to be_nil
            end

            it 'does not record anything' do
              expect(Payment::Braintree).not_to have_received(:write_customer)
              expect(Payment::Braintree).not_to have_received(:write_subscription)
            end
          end

          describe 'and is updated successfully' do
            before :each do
              allow(::Braintree::Customer).to receive(:update).and_return(customer_success)
            end

            describe 'but it fails to create payment method' do
              before :each do
                allow(::Braintree::PaymentMethod).to receive(:create).and_return(failure)
                @builder = subject.make_subscription(required_options)
              end

              it 'passes the right params to Braintree::PaymentMethod.create' do
                expect(::Braintree::PaymentMethod).to have_received(:create).with(payment_method_options)
              end

              it 'does not call Braintree::Subscription.create' do
                expect(::Braintree::Subscription).not_to have_received(:create)
              end

              it 'is not successful' do
                expect(@builder.success?).to be(false)
              end

              it "has '#action' as nil" do
                expect(@builder.action).to be_nil
              end

              it 'does not record anything' do
                expect(Payment::Braintree).not_to have_received(:write_customer)
                expect(Payment::Braintree).not_to have_received(:write_subscription)
              end
            end

            describe 'and payment method is created successfully' do
              before :each do
                allow(::Braintree::PaymentMethod).to receive(:create).and_return(payment_success)
              end

              describe 'but it fails to create subscription' do
                before :each do
                  allow(::Braintree::Subscription).to receive(:create).and_return(failure)
                  @builder = subject.make_subscription(required_options)
                end

                it 'passes the right params to Braintree::Subscription.create' do
                  expect(::Braintree::Subscription).to have_received(:create).with(subscription_options)
                end

                it 'is not successful' do
                  expect(@builder.success?).to be(false)
                end

                it "has '#action' as nil" do
                  expect(@builder.action).to be_nil
                end

                it 'does not record anything' do
                  expect(Payment::Braintree).not_to have_received(:write_customer)
                  expect(Payment::Braintree).not_to have_received(:write_subscription)
                end
              end

              describe 'and subscription is successfully created' do
                let!(:payment_method) { create(:payment_braintree_payment_method, customer: customer, token: 'qwertyuiop') }

                before :each do
                  allow(::Braintree::Subscription).to receive(:create).and_return(subscription_success)
                  allow(Payment::Braintree::BraintreeCustomerBuilder).to receive(:build).and_return(customer)
                  @builder = subject.make_subscription(required_options)
                end

                it 'passes the right params to Braintree::Customer.update' do
                  expect(::Braintree::Customer).to have_received(:update).with(customer.customer_id, customer_options)
                end

                it 'passes the right params to Braintree::PaymentMethod.create' do
                  expect(::Braintree::PaymentMethod).to have_received(:create).with(payment_method_options)
                end

                it 'passes the right params to Braintree::Subscription.create' do
                  expect(::Braintree::Subscription).to have_received(:create).with(subscription_options)
                end

                it 'is successful' do
                  expect(@builder.success?).to be(true)
                end

                it "has '#action' as the result from ManageBraintreeDonation.create" do
                  expect(@builder.action).to eq action
                end

                it 'calls Payment.write_customer with the correct payment method' do
                  expect(Payment::Braintree::BraintreeCustomerBuilder).to have_received(:build).with(
                    customer_success.customer, payment_success.payment_method, action.member_id, customer, store_in_vault: false
                  )
                end

                it 'calls Payment.write_subscription with the right params' do
                  expect(Payment::Braintree).to have_received(:write_subscription).with(payment_method.id, customer.customer_id, subscription_success, '12', 77, 'AUD')
                end
              end
            end
          end
        end

        describe 'customer does not exist' do
          let(:customer_options) do
            {
              first_name: 'Bob',
              last_name: 'Loblaw',
              email: 'bob.loblaw@law-blog.org',
              payment_method_nonce: required_options[:nonce],
              credit_card: {
                billing_address: {
                  first_name: 'Bob',
                  last_name: 'Loblaw',
                  country_code_alpha2: 'AU'
                }
              }
            }
          end
          let(:subscription_options) do
            {
              payment_method_token: customer_token,
              plan_id: 'AUD',
              price: '437.14',
              merchant_account_id: 'AUD'
            }
          end

          describe 'but it fails to create' do
            before :each do
              allow(::Braintree::Customer).to receive(:create).and_return(failure)
              @builder = subject.make_subscription(required_options)
            end

            it 'passes the right params to Braintree::Customer.create' do
              expect(::Braintree::Customer).to have_received(:create).with(customer_options)
            end

            it 'does not call any other Braintree methods' do
              expect(::Braintree::Customer).not_to have_received(:update)
              expect(::Braintree::PaymentMethod).not_to have_received(:create)
              expect(::Braintree::Subscription).not_to have_received(:create)
            end

            it 'is not successful' do
              expect(@builder.success?).to be(false)
            end

            it "has '#action' as nil" do
              expect(@builder.action).to be_nil
            end

            it 'does not record anything' do
              expect(Payment::Braintree).not_to have_received(:write_customer)
              expect(Payment::Braintree).not_to have_received(:write_subscription)
            end
          end

          describe 'and is created successfully' do
            before :each do
              allow(::Braintree::Customer).to receive(:create).and_return(customer_success)
            end

            describe 'but it fails to create subscription' do
              before :each do
                allow(::Braintree::Subscription).to receive(:create).and_return(failure)
                @builder = subject.make_subscription(required_options)
              end

              it 'passes the right params to Braintree::Subscription.create' do
                expect(::Braintree::Subscription).to have_received(:create).with(subscription_options)
              end

              it 'is not successful' do
                expect(@builder.success?).to be(false)
              end

              it "has '#action' as nil" do
                expect(@builder.action).to be_nil
              end

              it 'does not record anything' do
                expect(Payment::Braintree).not_to have_received(:write_customer)
                expect(Payment::Braintree).not_to have_received(:write_subscription)
              end
            end

            # The behvaiour tested by this block is already covered
            # in request/api/braintree/braintree_spec.rb. This whole spec file
            # is too dependent on stubs, and is too brittle to maintain.
            # FIXME: Needs urgent refactoring/culling.
            #
            xdescribe 'and subscription is successfully created' do
              let!(:customer) do
                build :payment_braintree_customer,
                      first_name: 'Bob',
                      last_name: 'Loblaw',
                      email: 'bob.loblaw@law-blog.org'
              end

              let!(:payment_method) { create :braintree_payment_method, customer: customer }

              let!(:customer) do
                build :payment_braintree_customer,
                      first_name: 'Bob',
                      last_name: 'Loblaw',
                      email: 'bob.loblaw@law-blog.org'
              end

              let!(:payment_method) { create :braintree_payment_method, customer: customer }

              before :each do
                allow(::Braintree::Subscription).to receive(:create).and_return(subscription_success)
                allow(Payment::Braintree).to receive(:write_customer).and_return(customer)
                @builder = subject.make_subscription(required_options)
              end

              it 'passes the right params to Braintree::Customer.create' do
                expect(::Braintree::Customer).to have_received(:create).with(customer_options)
              end

              it 'does not call Braintree::PaymentMethod.create' do
                expect(::Braintree::PaymentMethod).not_to have_received(:create)
              end

              it 'passes the right params to Braintree::Subscription.create' do
                expect(::Braintree::Subscription).to have_received(:create).with(subscription_options)
              end

              it 'is successful' do
                expect(@builder.success?).to be(true)
              end

              it "has '#action' as the result from ManageBraintreeDonation.create" do
                expect(@builder.action).to eq action
              end

              it "calls Payment.write_customer with the customer's payment method" do
                expect(Payment::Braintree).to have_received(:write_customer).with(
                  customer_success.customer, customer_success.customer.payment_methods.first, action.member_id, nil
                )
              end

              it 'calls Payment.write_subscription with the right params' do
                expect(Payment::Braintree).to have_received(:write_subscription).with(subscription_success, '12', 77, 'AUD')
              end
            end
          end
        end
      end
    end
  end
end
