class AddForeignKeyToTemplates < ActiveRecord::Migration
  def change
    add_foreign_key :campaign_pages, :templates
  end
end
