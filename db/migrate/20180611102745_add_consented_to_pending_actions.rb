class AddConsentedToPendingActions < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_actions, :consented, :boolean, defualt: false
  end
end
