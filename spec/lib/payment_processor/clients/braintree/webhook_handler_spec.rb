require 'rails_helper'

module PaymentProcessor
  module Clients
    module Braintree
      describe WebhookHandler do
        describe '.handle' do

          let(:action) { build :action, page_id: 1, member_id: 2 }
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
                allow(Action).to receive(:where).and_return([action])
                WebhookHandler.handle(notification)
              end

              it 'looks up action by subscription_id' do
                expect(Action).to have_received(:where).with('form_data @> ?', {
                  is_subscription: true,
                  subscription_id: notification.subscription.id
                }.to_json)
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
                allow(Action).to receive(:where).and_return([])
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
              allow(Action).to receive(:where)
              WebhookHandler.handle(notification)
            end

            it 'does not look up the action' do
              expect(Action).not_to have_received(:where)
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
