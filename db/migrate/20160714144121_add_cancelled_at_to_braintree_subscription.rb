# frozen_string_literal: true

class AddCancelledAtToBraintreeSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_braintree_subscriptions, :cancelled_at, :timestamp
  end
end
