class RemoveCountryFromPluginsCallTools < ActiveRecord::Migration[5.1]
  def change
    remove_column :plugins_call_tools, :target_by_country, :boolean, default: true
  end
end
