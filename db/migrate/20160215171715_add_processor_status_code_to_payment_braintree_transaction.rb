class AddProcessorStatusCodeToPaymentBraintreeTransaction < ActiveRecord::Migration
  def change
    add_column :payment_braintree_transactions, :processor_response_code, :string
  end
end
