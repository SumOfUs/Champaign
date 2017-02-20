class AddCountriesFlagToCallTools < ActiveRecord::Migration
  def change
    add_column :plugins_call_tools, :target_by_country, :boolean, default: true
  end
end
