# frozen_string_literal: true

class AddPaymentMethodIdToBraintreeSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_braintree_subscriptions, :payment_method_id, :integer
  end
end
