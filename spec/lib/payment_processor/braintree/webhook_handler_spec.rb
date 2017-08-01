# frozen_string_literal: true

require 'rails_helper'

describe PaymentProcessor::Braintree::WebhookHandler do
  def notification_faker(type, object_id)
    Braintree::WebhookTesting.sample_notification(
      type,
      object_id
    )
  end

  let(:member)       { create(:member) }
  let(:action)       { create(:action, member: member, form_data: { subscription_id: 'subscription_id' }) }
  let!(:customer)    { create(:payment_braintree_customer, member: member) }
  let(:subscription) do
    create(:payment_braintree_subscription,
           action: action,
           subscription_id: 'subscription_id',
           # The transaction amount given by Braintree on the test webhook
           amount: 49.99)
  end

  subject do
    PaymentProcessor::Braintree::WebhookHandler
      .handle(notification[:bt_signature], notification[:bt_payload])
  end

  describe 'subscription charged event' do
    context 'when subscription is found' do
      let(:notification) do
        notification_faker(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          subscription.subscription_id
        )
      end

      it 'returns true' do
        expect(subject).to be true
      end

      it 'writes transaction' do
        expect { subject }
          .to change { subscription.transactions.count }
          .from(0).to(1)
      end

      it 'posts a successful subscription payment event to the queue' do
        Timecop.freeze do
          expected_payload = {
            type: 'subscription-payment',
            params: {
              # Matches the only string format AK accepts, e.g. "2016-12-22 17:47:42"
              created_at: /\A\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}\z/,
              recurring_id: 'subscription_id',
              success: 1,
              status: 'completed',
              amount: /\A\d+[.]\d+\z/
            }
          }

          expect(ChampaignQueue).to receive(:push)
            .with(expected_payload,
                  group_id: "braintree-subscription:#{subscription.id}")

          subject
        end
      end
    end

    context 'when subscription is not found' do
      let(:notification) do
        notification_faker(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          'invalid_subscription_id'
        )
      end

      it 'does not write transaction' do
        expect { subject }
          .not_to change { subscription.transactions.count }
      end

      # We're failing silently if the subscription isn't persisted locally because we get a lot of webhooks
      # for subscriptions that were created on our legacy platform.
      it 'fails silently' do
        expect(Rails.logger).to_not receive(:error)
      end
    end
  end

  describe 'subscription cancelled event' do
    context 'when subscription is found' do
      let(:notification) do
        notification_faker(
          Braintree::WebhookNotification::Kind::SubscriptionCanceled,
          subscription.subscription_id
        )
      end

      it 'updates subscription' do
        expect { subject }.to change { subscription.reload.cancelled_at }
          .from(nil)
          .to(instance_of(ActiveSupport::TimeWithZone))
      end

      it 'pushes an event to the queue' do
        expect(ChampaignQueue).to receive(:push).with(
          { type: 'cancel_subscription',
            params: {
              recurring_id: 'subscription_id',
              canceled_by: 'processor'
            } },
          { group_id: "braintree-subscription:#{subscription.id}" }
        )
        subject
      end
    end
  end

  describe 'failed subscription charge' do
    let(:notification) do
      notification_faker(
        Braintree::WebhookNotification::Kind::SubscriptionChargedUnsuccessfully,
        subscription.subscription_id
      )
    end

    it 'creates a failed transaction locally' do
      expect { subject }
        .to change { subscription.transactions.count }
        .from(0).to(1)
      expect(subscription.transactions.first.status).to eq('failure')
    end

    it 'pushes a failed subscription charge event to the queue' do
      Timecop.freeze do
        expected_payload = {
          type: 'subscription-payment',
          params: {
            # Matches the only string format AK accepts, e.g. "2016-12-22 17:47:42"
            created_at: /\A\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}\z/,
            recurring_id: 'subscription_id',
            success: 0,
            status: 'failed',
            amount: '0.0'
          }
        }
        expect(ChampaignQueue).to receive(:push).with(
          expected_payload,
          group_id: "braintree-subscription:#{subscription.id}"
        )
        subject
      end
    end
  end

  # This describes the event where we have updated the subscription on the Braintree dashboard but not on Champaign
  describe 'subscription that comes in with a different amount from the original' do
    let(:action) { create(:action, member: member, form_data: { subscription_id: 'subscription_id' }) }

    let!(:existing_subscription) do
      create(:payment_braintree_subscription,
             action: action,
             subscription_id: 'subscription_id',
             amount: 5)
    end

    let(:notification) do
      notification_faker(
        Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
        existing_subscription.subscription_id
      )
    end

    let(:parsed_notification) do
      double('notification',
             bt_signature: 'bt_signature',
             bt_payload: 'bt_payload',
             kind: 'subscription_charged_successfully',
             subscription: double('notification_subscription',
                                  id: 'subscription_id',
                                  transactions: [double('transaction', amount: 10)]))
    end

    before do
      allow(::Braintree::WebhookNotification).to receive(:parse).and_return(parsed_notification)
    end

    it 'updates the local subscription record' do
      subject
      expect(existing_subscription.reload.amount).to eq 10
    end

    it 'publishes a subscription update event and a charge event with the new amount' do
      Timecop.freeze do
        payment_payload = {
          type: 'subscription-payment',
          params: {
            # Matches the only string format AK accepts, e.g. "2016-12-22 17:47:42"
            created_at: /\A\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}\z/,
            recurring_id: 'subscription_id',
            success: 1,
            status: 'completed',
            amount: '10.0'
          }
        }
        update_payload = {
          type: 'recurring_payment_update',
          params: {
            recurring_id: 'subscription_id',
            amount: '10.0'
          }
        }
        expect(ChampaignQueue).to receive(:push)
          .with(update_payload, group_id: "braintree-subscription:#{subscription.id}")
          .ordered
        expect(ChampaignQueue).to receive(:push)
          .with(payment_payload, group_id: "braintree-subscription:#{subscription.id}")
          .ordered

        subject
      end
    end
  end
end
