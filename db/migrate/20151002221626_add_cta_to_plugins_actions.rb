class AddCtaToPluginsActions < ActiveRecord::Migration
  def change
    add_column :plugins_actions, :cta, :string
  end
end
