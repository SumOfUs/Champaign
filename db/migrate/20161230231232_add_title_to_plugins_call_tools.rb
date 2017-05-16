# frozen_string_literal: true

class AddTitleToPluginsCallTools < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_call_tools, :title, :string
  end
end
