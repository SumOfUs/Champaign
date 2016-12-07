# frozen_string_literal: true
class AddPlegeFlagToPaymentBraintreeTransaction < ActiveRecord::Migration
  def change
    add_column :payment_braintree_transactions, :pledge, :boolean, default: false
    add_column :payment_braintree_transactions, :pledge_processed_at, :datetime
  end
end
