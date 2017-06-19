# frozen_string_literal: true

class AddDescriptionToPluginsActions < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_actions, :description, :text
  end
end
