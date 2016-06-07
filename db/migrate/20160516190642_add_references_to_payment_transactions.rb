class AddReferencesToPaymentTransactions < ActiveRecord::Migration
  def change
    add_reference :payment_braintree_transactions,   :subscription, references: :payment_braintree_subscription,   index: {name: 'braintree_transaction_subscription'}
    add_reference :payment_go_cardless_transactions, :subscription, references: :payment_go_cardless_subscription, index: {name: 'go_cardless_transaction_subscription'}
  end
end
