class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages, id: false, :primary_key => :language_code do |t|
      # Language code is set as primary key,
      # You'll also need to tell your model the name of its primary key via self.primary_key = "language_code"
      t.string :language_code, null: false #needs to be set unique
      t.string :language_name, null: false
    end
  end
end
