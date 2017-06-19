# frozen_string_literal: true

class AddRefToPlugins < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_actions, :ref, :string
    add_column :plugins_thermometers, :ref, :string
  end
end
