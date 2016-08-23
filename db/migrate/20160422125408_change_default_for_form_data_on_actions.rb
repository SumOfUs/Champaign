# frozen_string_literal: true
class ChangeDefaultForFormDataOnActions < ActiveRecord::Migration
  def change
    change_column_default(:actions, :form_data, {})
  end
end
