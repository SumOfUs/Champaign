# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_go_cardless_webhook_events
#
#  id            :integer          not null, primary key
#  event_id      :string
#  resource_type :string
#  action        :string
#  body          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :string
#

FactoryBot.define do
  factory :payment_go_cardless_webhook_event, class: 'Payment::GoCardless::WebhookEvent' do
    event_id 'MyString'
    resource_type 'MyString'
    action 'MyString'
  end
end
