class AddFieldsToBraintreePaymentMethod < ActiveRecord::Migration
  def change
    add_column :payment_braintree_payment_methods, :card_type, :string
    add_column :payment_braintree_payment_methods, :bin, :string
    add_column :payment_braintree_payment_methods, :cardholder_name, :string
    add_column :payment_braintree_payment_methods, :last_4, :string
  end
end
