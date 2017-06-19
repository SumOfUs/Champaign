# frozen_string_literal: true

class AddIndexToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_index :plugins_surveys, :page_id
  end
end
