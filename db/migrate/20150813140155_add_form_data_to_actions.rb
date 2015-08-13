class AddFormDataToActions < ActiveRecord::Migration
  def change
    add_column :actions, :form_data, :jsonb
  end
end
