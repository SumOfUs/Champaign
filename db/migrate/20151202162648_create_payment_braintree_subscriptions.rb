class CreatePaymentBraintreeSubscriptions < ActiveRecord::Migration
  def change
    create_table :payment_braintree_subscriptions do |t|
      t.string :subscription_id
      t.datetime :next_billing_date
      t.string :plan_id
      t.string :price
      t.string :status
      t.string :merchant_account_id
      t.string :customer_id

      t.timestamps null: false
    end
  end
end
