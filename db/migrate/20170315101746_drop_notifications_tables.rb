class DropNotificationsTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :payment_braintree_notifications
  end
end
