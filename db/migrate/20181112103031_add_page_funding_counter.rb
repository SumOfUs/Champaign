class AddPageFundingCounter < ActiveRecord::Migration[5.2]
  def change
    # The total donations column will be tallied in Settings.default_currency
    add_column :pages, :total_donations, :decimal, precision: 10, scale: 2, default: 0
    add_column :pages, :fundraising_goal, :decimal, precision: 10, scale: 2, default: 0
  end
end
