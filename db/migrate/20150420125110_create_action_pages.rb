class CreateActionPages < ActiveRecord::Migration
  def change
    create_table :action_pages, id: false do |t|
      t.primary_key :action_page_id
      t.string :title, null: false
      t.string :slug, null: false
      t.boolean :active, null: false
      t.boolean :featured, null: false
    end
    # adds foreign key called campaign_id to the campaign_id column in the campaigns table
    add_foreign_key :action_pages, :campaigns, column: :campaign_id, name: :campaign_id
    # adds a foreign key called language_code to the language_code column in the languages table
    add_foreign_key :action_pages, :languages, column: :language_code, name: :language_code
  end
end
