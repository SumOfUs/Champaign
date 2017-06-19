# frozen_string_literal: true

class RemoveActionReferenceFromGoCardlessTransaction < ActiveRecord::Migration[4.2]
  def change
    remove_column :payment_go_cardless_transactions, :action_id
  end
end
