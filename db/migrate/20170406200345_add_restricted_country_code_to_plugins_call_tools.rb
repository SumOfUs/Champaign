class AddRestrictedCountryCodeToPluginsCallTools < ActiveRecord::Migration
  def change
    add_column :plugins_call_tools, :restricted_country_code, :string
  end
end
