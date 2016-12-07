# frozen_string_literal: true
class AddPledgeFlagTopPluginsFundraisers < ActiveRecord::Migration
  def change
    add_column :plugins_fundraisers, :pledge, :boolean, default: false
    add_column :plugins_fundraisers, :pledge_processed_on, :datetime
    add_column :plugins_fundraisers, :pledge_target_in_actions, :integer, default: 0
  end
end
