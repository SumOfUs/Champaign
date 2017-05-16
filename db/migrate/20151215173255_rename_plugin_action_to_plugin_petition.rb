# frozen_string_literal: true

class RenamePluginActionToPluginPetition < ActiveRecord::Migration[4.2]
  def change
    rename_table :plugins_actions, :plugins_petitions
  end
end
