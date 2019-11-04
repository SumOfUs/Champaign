class ChangeEnforceStylesDefaultValue < ActiveRecord::Migration[5.2]
  def change
    change_column_default :pages, :enforce_styles, true
  end
end
