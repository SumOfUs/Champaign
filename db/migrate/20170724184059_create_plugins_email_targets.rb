class CreatePluginsEmailTargets < ActiveRecord::Migration[5.1]
  def change
    create_table :plugins_email_targets do |t|
      t.string :ref
      t.references :page, index: true
      t.boolean    :active, default: false
      t.integer    :page_id
      t.string     :ref
      t.string     :email_from
      t.string     :email_subject
      t.text       :email_body
      t.text       :email_body_header
      t.text       :email_body_footer
      t.string     :test_email_address
      t.json :targets, default: [], array: true
      t.timestamps
    end
  end
end
