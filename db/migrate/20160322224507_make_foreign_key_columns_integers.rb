class MakeForeignKeyColumnsIntegers < ActiveRecord::Migration
  def change
    change_column :payment_braintree_customers, :default_payment_method_id, 'integer USING CAST(default_payment_method_id AS integer)'
    change_column :payment_braintree_transactions, :payment_method_id, 'integer USING CAST(payment_method_id AS integer)'
  end
end
