class CreatePluginsEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :plugins_emails do |t|
      t.boolean :active, default: false
      t.boolean :spoof_member_email, default: false
      t.string :from
      t.string :ref
      t.string :subjects, array: true, default: []
      t.string :test_email_address
      t.string :title, default: ''
      t.text :template
      t.text :instructions
      t.references :page, index: true
      t.references :registered_email_address
      t.timestamps
    end
  end
end
