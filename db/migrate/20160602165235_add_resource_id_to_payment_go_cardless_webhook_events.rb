# frozen_string_literal: true

class AddResourceIdToPaymentGoCardlessWebhookEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_go_cardless_webhook_events, :resource_id, :string
  end
end
