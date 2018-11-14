class AddPageFundingCounter < ActiveRecord::Migration[5.2]
  def change
    # The total donations column will be tallied in USD
    add_column :pages, :total_donations, :decimal, precision: 10, scale: 2, default: 0
  end
end
