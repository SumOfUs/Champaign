class AddRefundToPaymentBraintreeTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_braintree_transactions, :amount_refunded, :decimal, precision: 8, scale: 2
    add_column :payment_braintree_transactions, :refunded_at,     :datetime
    add_column :payment_braintree_transactions, :refund,          :boolean, default: false
    add_column :payment_braintree_transactions, :refund_transaction_id, :string
  end
end
