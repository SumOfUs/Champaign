class CreatePluginsLinks < ActiveRecord::Migration
  def change
    create_table :plugins_links do |t|
      t.string :url
      t.string :title
      t.string :date
      t.string :source

      t.references :plugins_linkset, index: true, foreign_key: true
    end
  end
end
