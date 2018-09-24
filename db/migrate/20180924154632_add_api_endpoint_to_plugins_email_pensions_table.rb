class AddApiEndpointToPluginsEmailPensionsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :plugins_email_pensions, :registered_target_endpoint_id, :integer
  end
end
