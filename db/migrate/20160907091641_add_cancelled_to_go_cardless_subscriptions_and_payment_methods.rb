# frozen_string_literal: true

class AddCancelledToGoCardlessSubscriptionsAndPaymentMethods < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_go_cardless_subscriptions, :cancelled_at, :timestamp
    add_column :payment_go_cardless_payment_methods, :cancelled_at, :timestamp
  end
end
