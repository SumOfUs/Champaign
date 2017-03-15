class DropNotificationsTables < ActiveRecord::Migration
  def change
    drop_table :payment_braintree_notifications
  end
end
