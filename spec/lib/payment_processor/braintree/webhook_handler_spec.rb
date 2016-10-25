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
  let(:action)       { create(:action, member: member, form_data: { subscription_id: 'foo' }) }
  let!(:customer)    { create(:payment_braintree_customer, member: member) }
  let(:subscription) { create(:payment_braintree_subscription, action: action) }

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

      it 'writes notification' do
        subject

        record = Payment::Braintree::Notification.first

        expect(record.attributes).to include(
          'signature' => notification[:bt_signature],
          'payload'   => notification[:bt_payload]
        )
      end

      it 'posts events' do
        expected_payload = {
          type: 'subscription-payment',
          params: {
            recurring_id: 'foo'
          }
        }

        expect(ChampaignQueue).to receive(:push)
          .with(expected_payload, delay: 120)

        subject
      end
    end

    context 'when subscription is not found' do
      let(:notification) do
        notification_faker(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          'invalid_subscription_id'
        )
      end

      it 'returns false' do
        expect(subject).to be false
      end

      it 'does not write transaction' do
        expect { subject }
          .not_to change { subscription.transactions.count }
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:info)
          .with(/Failed to handle Braintree::WebhookNotification/)

        subject
      end

      it 'writes notification' do
        subject

        record = Payment::Braintree::Notification.first

        expect(record.attributes).to include(
          'signature' => notification[:bt_signature],
          'payload'   => notification[:bt_payload]
        )
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

      it 'writes notification' do
        subject

        record = Payment::Braintree::Notification.first

        expect(record.attributes).to include(
          'signature' => notification[:bt_signature],
          'payload'   => notification[:bt_payload]
        )
      end
    end
  end
end
