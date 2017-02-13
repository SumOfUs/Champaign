class AddPreselectAmountToPluginsFundraisers < ActiveRecord::Migration
  def change
    add_column :plugins_fundraisers, :preselect_amount, :boolean, default: false
  end
end
