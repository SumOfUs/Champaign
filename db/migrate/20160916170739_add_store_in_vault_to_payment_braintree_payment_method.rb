# frozen_string_literal: true

class AddStoreInVaultToPaymentBraintreePaymentMethod < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_braintree_payment_methods, :store_in_vault, :boolean, default: false
    add_index 'payment_braintree_payment_methods', ['store_in_vault'], name: 'index_payment_braintree_payment_methods_on_store_in_vault', using: :btree
  end
end
