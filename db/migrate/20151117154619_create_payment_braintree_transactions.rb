# frozen_string_literal: true

class CreatePaymentBraintreeTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_braintree_transactions do |t|
      t.string :transaction_id
      t.string :transaction_type
      t.string :status
      t.string :amount
      t.datetime :transaction_created_at
      t.string :payment_method_token
      t.string :customer_id

      t.timestamps null: false
    end
  end
end
