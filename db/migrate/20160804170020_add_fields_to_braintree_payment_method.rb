# frozen_string_literal: true

class AddFieldsToBraintreePaymentMethod < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_braintree_payment_methods, :card_type, :string
    add_column :payment_braintree_payment_methods, :bin, :string
    add_column :payment_braintree_payment_methods, :cardholder_name, :string
    add_column :payment_braintree_payment_methods, :last_4, :string
    add_column :payment_braintree_payment_methods, :expiration_date, :string
    add_column :payment_braintree_payment_methods, :instrument_type, :string
    add_column :payment_braintree_payment_methods, :email, :string
  end
end
