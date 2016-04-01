class MakeTransactionCustomerIdInteger < ActiveRecord::Migration
  def change
    rename_column :payment_braintree_transactions, :customer_id, :payment_braintree_customer_id
    change_column :payment_braintree_transactions, :payment_braintree_customer_id, 'integer USING CAST(payment_braintree_customer_id AS integer)'
  end
end
