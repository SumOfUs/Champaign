class CreateRegisteredTargetEndpoints < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_target_endpoints do |t|
      t.string :url
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
