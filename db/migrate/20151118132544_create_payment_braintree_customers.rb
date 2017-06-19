# frozen_string_literal: true

class CreatePaymentBraintreeCustomers < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_braintree_customers do |t|
      t.string :card_type
      t.string :card_bin
      t.string :cardholder_name
      t.string :card_debit
      t.string :card_last_4
      t.string :card_vault_token
      t.string :card_unqiue_number_identifier
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :customer_id

      t.timestamps null: false
    end
  end
end
