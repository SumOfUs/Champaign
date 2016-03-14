class MultiplePaymentMethodTokens < ActiveRecord::Migration
  def change
    create_table :braintree_payment_method_tokens do |t|
      t.string :customer_id
      t.string :braintree_payment_method_token
      t.timestamps null: false
    end
  end
end
