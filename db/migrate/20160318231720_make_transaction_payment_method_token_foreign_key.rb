class MakeTransactionPaymentMethodTokenForeignKey < ActiveRecord::Migration
  def change
    rename_column :payment_braintree_transactions, :payment_method_token, :payment_method_id
  end
end
