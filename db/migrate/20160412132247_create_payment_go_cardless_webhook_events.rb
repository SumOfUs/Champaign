class CreatePaymentGoCardlessWebhookEvents < ActiveRecord::Migration
  def change
    create_table :payment_go_cardless_webhook_events do |t|
      t.string :event_id, index: true
      t.string :resource_type
      t.string :action

      t.timestamps null: false
    end
  end
end
