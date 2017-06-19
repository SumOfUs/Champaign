class AdjustPluginsEmailTargetTable < ActiveRecord::Migration[4.2]
  def change
    rename_column :plugins_email_targets, :email_body, :email_body_b
    add_column :plugins_email_targets, :email_body_a, :text
    add_column :plugins_email_targets, :email_body_c, :text
  end
end
