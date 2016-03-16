class MultiplePaymentMethodTokens < ActiveRecord::Migration
  def change
    create_table :payment_braintree_payment_method_tokens do |t|
      t.string :braintree_customer_id
      t.string :braintree_payment_method_token
      t.timestamps null: false
    end
  end
end
