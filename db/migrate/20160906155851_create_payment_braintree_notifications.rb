# frozen_string_literal: true
class CreatePaymentBraintreeNotifications < ActiveRecord::Migration
  def change
    create_table :payment_braintree_notifications do |t|
      t.text :payload
      t.text :signature

      t.timestamps null: false
    end
  end
end
