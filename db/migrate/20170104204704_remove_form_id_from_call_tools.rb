# frozen_string_literal: true
class RemoveFormIdFromCallTools < ActiveRecord::Migration
  def change
    remove_column(:plugins_call_tools, :form_id)
  end
end
