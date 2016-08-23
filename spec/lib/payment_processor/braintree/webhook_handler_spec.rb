require 'rails_helper'

module PaymentProcessor
  module Braintree
    describe WebhookHandler do
      describe '.handle' do

        let(:subscription) { instance_double('Payment::BraintreeSubscription', transactions: transactions, action: action) }
        let(:transaction)  { double(:transaction, update: true) }
        let(:transactions) { [transaction] }
        let(:action) { create(:action, form_data: { subscription_id: '1234' }) }

        before :each do
          allow(Payment::Braintree).to receive(:write_transaction) { transaction }
          allow(ChampaignQueue).to receive(:push)
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
              allow(Payment::Braintree::Subscription).to receive(:find_by).and_return(subscription)
              WebhookHandler.handle(notification)
            end

            it 'looks up action by subscription_id' do
              expect(Payment::Braintree::Subscription).to have_received(:find_by).with(subscription_id: 's09870')
            end

            context 'with existing transactions' do
              it 'pushes the transaction to be queued' do
                expect(ChampaignQueue).to have_received(:push)
                  .with({type: "subscription-payment", params: { recurring_id: "1234" }})
              end
            end

            context 'with no existing transactions' do
              let(:transactions) { [] }

              it 'pushes the transaction to be queued' do
                expect(ChampaignQueue).to have_received(:push)
              end
            end

            it 'records to Payment.write_transaction' do
              expect(Payment::Braintree).to have_received(:write_transaction).with(
                notification, action.page_id, action.member_id, nil, false
              )
            end

            it 'does not log anything' do
              expect(Rails.logger).not_to have_received(:info)
            end
          end

          describe 'when Action is not found' do
            before :each do
              allow(Payment::Braintree::Subscription).to receive(:find_by).and_return(nil)
              WebhookHandler.handle(notification)
            end

            it 'does not write to Payment.write_transaction' do
              expect(Payment::Braintree).not_to have_received(:write_transaction)
            end

            it 'does not push to ChampaignQueue' do
              expect(ChampaignQueue).not_to have_received(:push)
            end

            it 'logs the failed handling' do
              expect(Rails.logger).to have_received(:info).with("Failed to handle Braintree::WebhookNotification for subscription_id 's09870'")
            end
          end
        end

        describe 'with unknown event' do
          let(:notification) do
            instance_double('Braintree::WebhookNotification', kind: 'unknown',
                            subscription: instance_double('Braintree::Subscription', id: 's09870')
                           )
          end

          before :each do
            allow(Payment::Braintree::Subscription).to receive(:find_by){ subscription }
            WebhookHandler.handle(notification)
          end

          it 'does not push to ChampaignQueue' do
            expect(ChampaignQueue).not_to have_received(:push)
          end

          it 'logs the failed handling' do
            expect(Rails.logger).to have_received(:info).with("Unsupported Braintree::WebhookNotification received of type 'unknown'")
          end
        end

        describe 'with subscription cancelation' do
          let(:subscription) { double(update: true ) }

          let(:notification) do
            instance_double('Braintree::WebhookNotification', kind: 'subscription_canceled',
                            subscription: instance_double('Braintree::Subscription', id: 's09870')
                           )
          end

          before :each do
            allow(Payment::Braintree::Subscription).to receive(:find_by){ subscription }
            WebhookHandler.handle(notification)
          end

          it 'updates subscription' do
            expect(subscription).to have_received(:update).with(cancelled_at: instance_of(Time))
          end

          it 'does not push to ChampaignQueue' do
            expect(ChampaignQueue).not_to have_received(:push)
          end
        end
      end
    end
  end
end
