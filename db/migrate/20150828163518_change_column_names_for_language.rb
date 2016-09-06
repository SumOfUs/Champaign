# frozen_string_literal: true
class ChangeColumnNamesForLanguage < ActiveRecord::Migration
  def change
    rename_column :languages, :language_code, :code
    rename_column :languages, :language_name, :name
  end
end
