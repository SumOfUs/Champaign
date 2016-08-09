class AddMissingFieldsToSubscriptions < ActiveRecord::Migration
  def change
    add_column :payment_braintree_subscriptions, :billing_day_of_month, :integer
  end
end
