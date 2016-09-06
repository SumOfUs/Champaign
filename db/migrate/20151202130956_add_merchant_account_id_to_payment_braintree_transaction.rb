# frozen_string_literal: true
class AddMerchantAccountIdToPaymentBraintreeTransaction < ActiveRecord::Migration
  def change
    add_column :payment_braintree_transactions, :merchant_account_id, :string
    add_column :payment_braintree_transactions, :currency, :string
  end
end
