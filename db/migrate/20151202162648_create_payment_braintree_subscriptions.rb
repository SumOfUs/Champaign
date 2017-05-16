# frozen_string_literal: true

class CreatePaymentBraintreeSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_braintree_subscriptions do |t|
      t.string :subscription_id
      t.string :price
      t.string :merchant_account_id

      t.timestamps null: false
    end
  end
end
