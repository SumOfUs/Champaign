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

require 'rails_helper'

RSpec.describe Payment::GoCardless::WebhookEvent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
