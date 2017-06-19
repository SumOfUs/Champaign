# frozen_string_literal: true

class AddActiveToTemplateTable < ActiveRecord::Migration[4.2]
  def change
    add_column :templates, :active, :boolean
  end
end
