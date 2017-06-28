class AddAutoAdvanceToPluginsSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_surveys, :auto_advance, :boolean, default: true
  end
end
