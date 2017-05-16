# frozen_string_literal: true

class AddActionIdToSubscription < ActiveRecord::Migration[4.2]
  def change
    add_reference :payment_braintree_subscriptions, :action, index: true
    add_index :payment_braintree_subscriptions, :subscription_id
  end
end
