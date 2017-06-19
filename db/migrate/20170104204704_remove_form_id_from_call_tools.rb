# frozen_string_literal: true

class RemoveFormIdFromCallTools < ActiveRecord::Migration[4.2]
  def change
    remove_column(:plugins_call_tools, :form_id)
  end
end
