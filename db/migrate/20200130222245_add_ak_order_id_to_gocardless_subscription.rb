class AddAkOrderIdToGocardlessSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_go_cardless_subscriptions, :ak_order_id, :string
  end
end
