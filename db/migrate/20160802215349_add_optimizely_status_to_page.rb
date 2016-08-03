class AddOptimizelyStatusToPage < ActiveRecord::Migration
  def change
    add_column :pages, :optimizely_status, :integer, null: false, default: 0
  end
end
