class AddAutoAdvanceToPluginsSurveys < ActiveRecord::Migration
  def change
    add_column :plugins_surveys, :auto_advance, :boolean, default: true
  end
end
