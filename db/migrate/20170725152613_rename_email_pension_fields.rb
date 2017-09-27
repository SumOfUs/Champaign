class RenameEmailPensionFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :plugins_email_pensions, :email_body_a, :email_body_header
    rename_column :plugins_email_pensions, :email_body_b, :email_body
    rename_column :plugins_email_pensions, :email_body_c, :email_body_footer
  end
end
