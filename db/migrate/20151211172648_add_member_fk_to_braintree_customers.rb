# frozen_string_literal: true

class AddMemberFkToBraintreeCustomers < ActiveRecord::Migration[4.2]
  def change
    add_reference :payment_braintree_customers, :member, index: true, foreign_key: true
  end
end
