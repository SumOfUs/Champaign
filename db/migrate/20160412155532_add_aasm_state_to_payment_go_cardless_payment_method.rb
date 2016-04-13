class AddAasmStateToPaymentGoCardlessPaymentMethod < ActiveRecord::Migration
  def change
    add_column :payment_go_cardless_payment_methods, :aasm_state, :string, index: true
    add_column :payment_go_cardless_subscriptions, :aasm_state, :string, index: true
    add_column :payment_go_cardless_transactions, :aasm_state, :string, index: true
  end
end
