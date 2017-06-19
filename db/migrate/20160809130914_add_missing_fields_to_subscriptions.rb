# frozen_string_literal: true

class AddMissingFieldsToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_braintree_subscriptions, :billing_day_of_month, :integer
  end
end
