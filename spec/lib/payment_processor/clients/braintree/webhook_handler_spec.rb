require 'rails_helper'

module PaymentProcessor
  module Clients
    module Braintree
      describe WebhookHandler do
        describe '.handle' do

          let(:subscription) { instance_double('Payment::BraintreeSubscription', action: action) }
          let(:action) { create(:action, form_data: {recurrence_number: 0 }) }

          before :each do
            allow(Payment).to receive(:write_transaction)
            allow(ActionQueue::Pusher).to receive(:push)
            allow(Rails.logger).to receive(:info)
          end

          describe 'with successful subscription charge' do

            let(:notification) do
              instance_double('Braintree::WebhookNotification', kind: 'subscription_charged_successfully',
                subscription: instance_double('Braintree::Subscription', id: 's09870')
              )
            end

            describe 'when Action is found' do

              before :each do
                allow(Payment::BraintreeSubscription).to receive(:find_by).and_return(subscription)
                WebhookHandler.handle(notification)
              end

              it 'looks up action by subscription_id' do
                expect(Payment::BraintreeSubscription).to have_received(:find_by).with(subscription_id: 's09870')
              end

              it 'pushes the action to ActionQueue::Pusher' do
                expect(ActionQueue::Pusher).to have_received(:push).with(action)
              end

              it 'records to Payment.write_transaction' do
                expect(Payment).to have_received(:write_transaction).with(
                  notification, action.page_id, action.member_id, nil, false
                )
              end

              it 'does not log anything' do
                expect(Rails.logger).not_to have_received(:info)
              end
            end

            describe 'when Action is not found' do

              before :each do
                allow(Payment::BraintreeSubscription).to receive(:find_by).and_return(nil)
                WebhookHandler.handle(notification)
              end

              it 'does not write to Payment.write_transaction' do
                expect(Payment).not_to have_received(:write_transaction)
              end

              it 'does not push to ActionQueue::Pusher' do
                expect(ActionQueue::Pusher).not_to have_received(:push)
              end

              it 'logs the failed handling' do
                expect(Rails.logger).to have_received(:info).with("Failed to handle Braintree::WebhookNotification for subscription_id 's09870'")
              end
            end
          end

          describe 'with subscription cancelation' do

            let(:notification) do
              instance_double('Braintree::WebhookNotification', kind: 'subscription_canceled',
                subscription: instance_double('Braintree::Subscription', id: 's09870')
              )
            end

            before :each do
              allow(Payment::BraintreeSubscription).to receive(:find_by)
              WebhookHandler.handle(notification)
            end

            it 'does not look up the action' do
              expect(Payment::BraintreeSubscription).not_to have_received(:find_by)
            end

            it 'does not write to Payment.write_transaction' do
              expect(Payment).not_to have_received(:write_transaction)
            end

            it 'does not push to ActionQueue::Pusher' do
              expect(ActionQueue::Pusher).not_to have_received(:push)
            end

            it 'logs the failed handling' do
              expect(Rails.logger).to have_received(:info).with("Unsupported Braintree::WebhookNotification received of type 'subscription_canceled'")
            end
          end
        end
      end
    end
  end
end
