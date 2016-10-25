# frozen_string_literal: true
class AddIndexToSurvey < ActiveRecord::Migration
  def change
    add_index :plugins_surveys, :page_id
  end
end
