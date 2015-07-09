class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.attachment :content
      t.integer :widget_id
    end
  end
end
