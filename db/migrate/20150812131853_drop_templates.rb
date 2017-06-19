# frozen_string_literal: true

class DropTemplates < ActiveRecord::Migration[4.2]
  def change
    drop_table :templates
  end
end
