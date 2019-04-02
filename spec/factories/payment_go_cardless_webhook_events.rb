# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_webhook_events
#
#  id            :integer          not null, primary key
#  action        :string
#  body          :text
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  event_id      :string
#  resource_id   :string
#
# Indexes
#
#  index_payment_go_cardless_webhook_events_on_event_id  (event_id)
#

FactoryBot.define do
  factory :payment_go_cardless_webhook_event, class: 'Payment::GoCardless::WebhookEvent' do
    event_id { 'MyString' }
    resource_type { 'MyString' }
    action { 'MyString' }
  end
end
