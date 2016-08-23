# frozen_string_literal: true
class AddJavascriptToPage < ActiveRecord::Migration
  def change
    add_column :pages, :javascript, :text
  end
end
