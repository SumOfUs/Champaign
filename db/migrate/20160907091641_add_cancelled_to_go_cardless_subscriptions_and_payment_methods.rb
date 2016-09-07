class AddCancelledToGoCardlessSubscriptionsAndPaymentMethods < ActiveRecord::Migration
  def change
      add_column :payment_go_cardless_subscriptions, :cancelled_at, :timestamp
      add_column :payment_go_cardless_payment_methods, :cancelled_at, :timestamp
  end
end
