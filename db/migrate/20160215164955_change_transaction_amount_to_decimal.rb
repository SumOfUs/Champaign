# frozen_string_literal: true

class ChangeTransactionAmountToDecimal < ActiveRecord::Migration[4.2]
  def change
    remove_column :payment_braintree_transactions, :amount
    add_column    :payment_braintree_transactions, :amount, :decimal, precision: 10, scale: 2
  end
end
