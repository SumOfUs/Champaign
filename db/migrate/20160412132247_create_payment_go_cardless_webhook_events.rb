# frozen_string_literal: true

class CreatePaymentGoCardlessWebhookEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_go_cardless_webhook_events do |t|
      t.string :event_id, index: true
      t.string :resource_type
      t.string :action
      t.text :body

      t.timestamps null: false
    end
  end
end
