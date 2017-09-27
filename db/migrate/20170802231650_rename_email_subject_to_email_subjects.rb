class RenameEmailSubjectToEmailSubjects < ActiveRecord::Migration[5.1]
  def change
    rename_column :plugins_email_pensions, :email_subject, :email_subjects
    rename_column :plugins_email_tools, :email_subject, :email_subjects
  end
end
