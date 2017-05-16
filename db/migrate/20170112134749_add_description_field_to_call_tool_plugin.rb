# frozen_string_literal: true

class AddDescriptionFieldToCallToolPlugin < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_call_tools, :description, :text
  end
end
