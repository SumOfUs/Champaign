class RenameCardVaultToken < ActiveRecord::Migration
  def change
    rename_column :payment_braintree_customers, :card_vault_token, :default_payment_method_token
  end
end
