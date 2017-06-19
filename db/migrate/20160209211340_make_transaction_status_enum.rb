# frozen_string_literal: true

class MakeTransactionStatusEnum < ActiveRecord::Migration[4.2]
  def up
    remove_column :payment_braintree_transactions, :status
    add_column :payment_braintree_transactions, :status, :integer
  end

  def down
    remove_column :payment_braintree_transactions, :status
    add_column :payment_braintree_transactions, :status, :string
  end
end
