# frozen_string_literal: true
class AddActionCountToPage < ActiveRecord::Migration
  def change
    add_column :pages, :action_count, :integer, default: 0
  end
end
