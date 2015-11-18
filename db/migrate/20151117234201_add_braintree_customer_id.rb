class AddBraintreeCustomerId < ActiveRecord::Migration
  def change
      add_column :action_users, :braintree_customer_id, :string
  end
end
