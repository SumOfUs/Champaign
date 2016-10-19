# frozen_string_literal: true
class AddCancelledAtToBraintreePaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_braintree_payment_methods, :cancelled_at, :timestamp
  end
end
