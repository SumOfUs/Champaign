class ChangeTransactionAmountToDecimal < ActiveRecord::Migration
  def change
    remove_column :payment_braintree_transactions, :amount
    add_column    :payment_braintree_transactions, :amount, :decimal, precision: 10, scale: 2
  end
end
