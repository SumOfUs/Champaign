class AddMemberFkToBraintreeCustomers < ActiveRecord::Migration
  def change
    add_reference :payment_braintree_customers, :member, index: true, foreign_key: true
  end
end
