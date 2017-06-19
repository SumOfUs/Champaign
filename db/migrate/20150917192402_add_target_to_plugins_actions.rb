# frozen_string_literal: true

class AddTargetToPluginsActions < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_actions, :target, :string
  end
end
