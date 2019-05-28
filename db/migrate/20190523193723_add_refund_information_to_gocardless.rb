class AddRefundInformationToGocardless < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_go_cardless_transactions, :refunded_at,           :datetime
    add_column :payment_go_cardless_transactions, :refund_transaction_id, :string
    add_column :payment_go_cardless_transactions, :refund,                :boolean, default: false
  end
end
