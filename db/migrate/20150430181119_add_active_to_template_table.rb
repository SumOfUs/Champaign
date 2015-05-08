class AddActiveToTemplateTable < ActiveRecord::Migration
  def change
    add_column :templates, :active, :boolean
  end
end
