# frozen_string_literal: true

class AddFormDataToActions < ActiveRecord::Migration[4.2]
  def change
    add_column :actions, :form_data, :jsonb
  end
end
