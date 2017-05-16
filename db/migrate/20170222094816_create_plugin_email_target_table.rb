class CreatePluginEmailTargetTable < ActiveRecord::Migration[4.2]
  def change
    create_table :plugins_email_targets do |t|
      t.string :ref
      t.references :page, index: true
      t.boolean :active, default: false
      t.integer  :page_id
      t.string   :ref
      t.string   :email_from
      t.string   :email_subject
      t.text     :email_body
      t.timestamps
    end
  end
end
