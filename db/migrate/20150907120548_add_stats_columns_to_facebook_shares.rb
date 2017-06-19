# frozen_string_literal: true

class AddStatsColumnsToFacebookShares < ActiveRecord::Migration[4.2]
  def change
    add_column :share_facebooks, :share_count, :integer
    add_column :share_facebooks, :click_count, :integer
  end
end
