# frozen_string_literal: true

class AddReferencesToPaymentTransactions < ActiveRecord::Migration[4.2]
  def change
    add_reference :payment_braintree_transactions,   :subscription, references: :payment_braintree_subscription,   index: { name: 'braintree_transaction_subscription' }
    add_reference :payment_go_cardless_transactions, :subscription, references: :payment_go_cardless_subscription, index: { name: 'go_cardless_transaction_subscription' }
  end
end
