# frozen_string_literal: true

class CreatePluginsCallTool < ActiveRecord::Migration[4.2]
  def change
    create_table :plugins_call_tools do |t|
      t.integer :page_id
      t.boolean :active
      t.string  :ref
      t.integer :form_id
      t.json    :targets
      t.timestamps
    end
  end
end
