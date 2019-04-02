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

require 'rails_helper'

RSpec.describe Payment::GoCardless::WebhookEvent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
