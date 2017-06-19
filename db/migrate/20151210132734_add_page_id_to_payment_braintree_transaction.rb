# frozen_string_literal: true

class AddPageIdToPaymentBraintreeTransaction < ActiveRecord::Migration[4.2]
  def change
    add_reference :payment_braintree_transactions, :page, index: true, foreign_key: true
    add_reference :payment_braintree_subscriptions, :page, index: true, foreign_key: true
  end
end
