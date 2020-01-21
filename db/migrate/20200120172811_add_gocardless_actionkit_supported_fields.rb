class AddGocardlessActionkitSupportedFields < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_go_cardless_transactions, :ak_order_id,           :string
    add_column :payment_go_cardless_transactions, :ak_donation_action_id, :string
    add_column :payment_go_cardless_transactions, :ak_transaction_id,     :string
    add_column :payment_go_cardless_transactions, :ak_user_id,            :string
  end
end
