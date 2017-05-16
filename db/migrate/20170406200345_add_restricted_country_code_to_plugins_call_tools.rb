class AddRestrictedCountryCodeToPluginsCallTools < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_call_tools, :restricted_country_code, :string
  end
end
