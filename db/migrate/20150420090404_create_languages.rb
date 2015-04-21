class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :language_code, null: false 
      t.string :language_name, null: false
      t.timestamps
    end
  end
end
