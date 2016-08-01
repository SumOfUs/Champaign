class CreateUris < ActiveRecord::Migration
  def change
    create_table :uris do |t|
      t.string :domain
      t.string :path
      t.references :page, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
