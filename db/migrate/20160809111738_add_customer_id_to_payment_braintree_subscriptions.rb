# frozen_string_literal: true

class AddCustomerIdToPaymentBraintreeSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_braintree_subscriptions, :customer_id, :string, index: true
  end
end
