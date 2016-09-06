# frozen_string_literal: true
class DropTemplates < ActiveRecord::Migration
  def change
    drop_table :templates
  end
end
