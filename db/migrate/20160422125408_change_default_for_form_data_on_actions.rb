# frozen_string_literal: true

class ChangeDefaultForFormDataOnActions < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:actions, :form_data, {})
  end
end
