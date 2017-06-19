# frozen_string_literal: true

class CreatePluginsSurvey < ActiveRecord::Migration[4.2]
  def change
    create_table :plugins_surveys do |t|
      t.integer  'page_id'
      t.boolean  'active', default: false
      t.string   'ref'

      t.timestamps
    end
  end
end
