# frozen_string_literal: true
class AddCancelledAtToBraintreeSubscription < ActiveRecord::Migration
  def change
    add_column :payment_braintree_subscriptions, :cancelled_at, :timestamp
  end
end
