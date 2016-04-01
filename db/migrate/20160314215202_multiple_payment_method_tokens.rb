class MultiplePaymentMethodTokens < ActiveRecord::Migration
  def change
    create_table :payment_braintree_payment_methods do |t|
      t.string :customer_id
      t.string :token
      t.timestamps null: false
    end
  end
end
