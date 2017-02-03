# frozen_string_literal: true
class AddEnforceStylesToPages < ActiveRecord::Migration
  def change
    add_column :pages, :enforce_styles, :boolean, default: false, null: false
  end
end
