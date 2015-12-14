class UpdateBraintreeCustomer < ActiveRecord::Migration
  def change
    rename_column :payment_braintree_customers, :card_vault_token, :default_payment_method_token
    change_table :payment_braintree_customers do |t|
      t.remove :card_unqiue_number_identifier,
               :email,
               :first_name,
               :last_name
    end
  end
end
