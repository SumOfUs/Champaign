# frozen_string_literal: true
class AddDescriptionToPluginsActions < ActiveRecord::Migration
  def change
    add_column :plugins_actions, :description, :text
  end
end
