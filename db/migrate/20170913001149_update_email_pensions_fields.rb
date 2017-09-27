class UpdateEmailPensionsFields < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins_email_pensions, :use_member_email, :boolean, default: false
    add_column :plugins_email_pensions, :from_email_address_id, :integer
    remove_column :plugins_email_pensions, :name_from
    remove_column :plugins_email_pensions, :email_from
  end
end
