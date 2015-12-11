class CreatePluginsFundraisers < ActiveRecord::Migration
  def change
    create_table :plugins_fundraisers do |t|
      t.string :title
      t.string :ref
      t.references :page, index: true, foreign_key: true
      t.boolean :active, default: false

      t.timestamps null: false
    end
  end
end
