class AddAasmStateToPaymentGoCardlessPaymentMethod < ActiveRecord::Migration
  def change
    add_column :payment_go_cardless_payment_methods, :aasm_state, :string
  end
end
