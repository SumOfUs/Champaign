class CreatePluginsLinksets < ActiveRecord::Migration
  def change
    create_table :plugins_linksets do |t|
      t.references :campaign_page, index: true, foreign_key: true
      t.string     :ref
      t.boolean    :active, default: false
      t.timestamps null: false
    end
  end
end
