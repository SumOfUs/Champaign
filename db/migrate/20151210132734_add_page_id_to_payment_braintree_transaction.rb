class AddPageIdToPaymentBraintreeTransaction < ActiveRecord::Migration
  def change
    add_reference :payment_braintree_transactions, :page, index: true, foreign_key: true
    add_reference :payment_braintree_subscriptions, :page, index: true, foreign_key: true
  end
end
