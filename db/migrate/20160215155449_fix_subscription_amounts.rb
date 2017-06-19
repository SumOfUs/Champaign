# frozen_string_literal: true

class FixSubscriptionAmounts < ActiveRecord::Migration[4.2]
  def change
    remove_column :payment_braintree_subscriptions, :price
    add_column    :payment_braintree_subscriptions, :amount, :decimal, precision: 10, scale: 2
    add_column    :payment_braintree_subscriptions, :currency, :string
  end
end
