class AddActionIdToSubscription < ActiveRecord::Migration
  def change
    add_reference :payment_braintree_subscriptions, :action, index: true
    add_index :payment_braintree_subscriptions, :subscription_id
  end
end
