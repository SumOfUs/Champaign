class ConvertEmailSubjectsToArray < ActiveRecord::Migration[5.1]
  def up
    change_column :plugins_email_pensions, :email_subject, :string, array: true, default: [], using: "(string_to_array(email_subject, ','))"
    change_column :plugins_email_tools,    :email_subject, :string, array: true, default: [], using: "(string_to_array(email_subject, ','))"
  end

  def down
    change_column :plugins_email_pensions, :email_subject, :string, array: false, default: nil, using: "(array_to_string(email_subject, ','))"
    change_column :plugins_email_tools,    :email_subject, :string, array: false, default: nil, using: "(array_to_string(email_subject, ','))"
  end
end
