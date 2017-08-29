class AddUseMemberEmailToEmailTargets < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins_email_tools, :use_member_email, :boolean, default: false
  end
end
