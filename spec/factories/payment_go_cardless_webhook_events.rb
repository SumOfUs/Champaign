# frozen_string_literal: true
FactoryGirl.define do
  factory :payment_go_cardless_webhook_event, class: 'Payment::GoCardless::WebhookEvent' do
    event_id 'MyString'
    resource_type 'MyString'
    action 'MyString'
  end
end
