# frozen_string_literal: true
class AddNotesToPage < ActiveRecord::Migration
  def change
    add_column :pages, :notes, :text
  end
end
