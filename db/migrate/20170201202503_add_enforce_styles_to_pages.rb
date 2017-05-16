# frozen_string_literal: true

class AddEnforceStylesToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :enforce_styles, :boolean, default: false, null: false
  end
end
