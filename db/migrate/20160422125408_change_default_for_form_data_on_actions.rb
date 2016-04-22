class ChangeDefaultForFormDataOnActions < ActiveRecord::Migration
  def change
    change_column_default(:actions, :form_data, {})
  end
end
