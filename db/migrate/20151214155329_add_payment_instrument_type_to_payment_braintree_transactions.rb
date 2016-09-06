# frozen_string_literal: true
class AddPaymentInstrumentTypeToPaymentBraintreeTransactions < ActiveRecord::Migration
  def change
    add_column :payment_braintree_transactions, :payment_instrument_type, :string
  end
end
