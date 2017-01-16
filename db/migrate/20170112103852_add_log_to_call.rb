# frozen_string_literal: true
class AddLogToCall < ActiveRecord::Migration
  def change
    add_column :calls, :log, :jsonb, null: false, default: '{}'
    add_index  :calls, :log, using: :gin
  end
end
