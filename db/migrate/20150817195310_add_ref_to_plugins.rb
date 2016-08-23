# frozen_string_literal: true
class AddRefToPlugins < ActiveRecord::Migration
  def change
    add_column :plugins_actions, :ref, :string
    add_column :plugins_thermometers, :ref, :string
  end
end
