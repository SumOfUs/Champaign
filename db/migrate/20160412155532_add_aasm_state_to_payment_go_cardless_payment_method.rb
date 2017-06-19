# frozen_string_literal: true

class AddAasmStateToPaymentGoCardlessPaymentMethod < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_go_cardless_payment_methods, :aasm_state, :string, index: true
    add_column :payment_go_cardless_subscriptions, :aasm_state, :string, index: true
    add_column :payment_go_cardless_transactions, :aasm_state, :string, index: true
  end
end
