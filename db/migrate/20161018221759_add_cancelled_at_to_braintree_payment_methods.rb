# frozen_string_literal: true

class AddCancelledAtToBraintreePaymentMethods < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_braintree_payment_methods, :cancelled_at, :timestamp
  end
end
