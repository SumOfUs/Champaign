class AddPublishToActions < ActiveRecord::Migration
  def change
    add_column :pages, :publish_actions, :integer, default: 0, null: false
    add_column :actions, :publish_status, :integer, default: 0, null: false
  end
end
