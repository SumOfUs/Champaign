# frozen_string_literal: true

class AddJavascriptToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :javascript, :text
  end
end
