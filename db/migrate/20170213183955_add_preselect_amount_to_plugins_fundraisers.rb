class AddPreselectAmountToPluginsFundraisers < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_fundraisers, :preselect_amount, :boolean, default: false
  end
end
