# frozen_string_literal: true
class AddPaymentMethodIdToBraintreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :payment_braintree_subscriptions, :payment_method_id, :integer
  end
end
