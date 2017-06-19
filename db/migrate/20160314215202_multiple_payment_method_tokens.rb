# frozen_string_literal: true

class MultiplePaymentMethodTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_braintree_payment_methods do |t|
      t.string :token
      t.timestamps null: false
      t.references :customer, index: { name: 'braintree_customer_index' }
    end

    add_column :payment_braintree_transactions, :payment_method_id, :integer
    add_index  :payment_braintree_transactions, :payment_method_id, name: 'braintree_payment_method_index'
  end
end
