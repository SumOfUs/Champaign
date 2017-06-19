class AddCountriesFlagToCallTools < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_call_tools, :target_by_country, :boolean, default: true
  end
end
