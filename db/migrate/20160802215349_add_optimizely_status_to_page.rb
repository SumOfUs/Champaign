# frozen_string_literal: true

class AddOptimizelyStatusToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :optimizely_status, :integer, null: false, default: 0
  end
end
